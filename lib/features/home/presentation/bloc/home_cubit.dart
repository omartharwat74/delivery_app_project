import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/auth_event_bus.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/device_id_helper.dart';
import '../../../auth/data/models/driver_model.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final SharedPreferences sharedPreferences;
  final LocationService locationService;
  final NotificationService notificationService;
  final AuthEventBus authEventBus;

  StreamSubscription<void>? _unauthorizedSubscription;
  StreamSubscription<String?>? _blockedSubscription;
  StreamSubscription<void>? _unblockedSubscription;
  bool _isUnauthorized = false;

  HomeCubit({
    required this.homeRepository,
    required this.sharedPreferences,
    LocationService? locationService,
    NotificationService? notificationService,
    AuthEventBus? authEventBus,
  })  : locationService = locationService ?? LocationServiceImpl(),
        notificationService = notificationService ?? NotificationServiceImpl(),
        authEventBus = authEventBus ?? AuthEventBus(),
        super(const HomeInitial()) {
    _unauthorizedSubscription = this.authEventBus.onUnauthorized.listen((_) {
      _isUnauthorized = true;
    });
    _blockedSubscription = this.authEventBus.onAccountBlocked.listen((_) {
      final currentDriver = state.driver;
      if (currentDriver != null) {
        emit(HomeLoaded(
          isOnline: false,
          driver: currentDriver.copyWith(status: 'blocked'),
        ));
      }
    });
    _unblockedSubscription = this.authEventBus.onAccountUnblocked.listen((_) async {
      final currentDriver = state.driver;
      if (currentDriver != null && currentDriver.status.toLowerCase() == 'blocked') {
        // Driver was unblocked! Update status to active/pending
        final cached = await homeRepository.getCachedDriver();
        final effective = cached ?? currentDriver.copyWith(status: 'active');
        emit(HomeLoaded(
          isOnline: effective.isOnline,
          driver: effective,
        ));
      }
    });
  }

  /// Initializes home screen silently:
  /// 1. Reads cached driver / online status and emits [HomeLoaded].
  /// 2. Silently updates FCM token from real device.
  /// 3. Silently updates current device location from GPS.
  Future<void> initHome({
    String? fcmToken,
    double? lat,
    double? lng,
    void Function()? onOrderOfferChime,
  }) async {
    if (_isUnauthorized) return;

    // Initialize notification service listeners for FCM chime & token refresh
    notificationService.initialize(
      onTokenRefresh: (newToken) => _updateFcmSilently(fcmToken: newToken),
      onOrderOfferChime: onOrderOfferChime,
    );

    // 1. Load initial driver & online status from local cache
    final cachedDriver = await homeRepository.getCachedDriver();
    final isOnline =
        cachedDriver?.isOnline ?? await homeRepository.getCachedOnlineStatus();

    if (_isUnauthorized) return;

    emit(HomeLoaded(isOnline: isOnline, driver: cachedDriver));

    // 2. Silently update FCM token & location in background
    await Future.wait([
      _updateFcmSilently(fcmToken: fcmToken),
      _updateLocationSilently(lat: lat, lng: lng),
    ]);
  }

  /// Explicitly updates FCM token on the backend (e.g. directly after login or permission grant)
  Future<void> updateFcmToken({String? fcmToken}) =>
      _updateFcmSilently(fcmToken: fcmToken);

  Future<void> _updateFcmSilently({String? fcmToken}) async {
    if (_isUnauthorized) return;
    try {
      final token = fcmToken ?? await notificationService.getFcmToken();
      if (token == null || token.isEmpty || _isUnauthorized) {
        // Permission denied or unavailable; safely ignore
        return;
      }

      final deviceId = await DeviceIdHelper.getDeviceId(sharedPreferences);
      final platform =
          Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'flutter';

      final result = await homeRepository.updateFcmToken(
        deviceId: deviceId,
        fcmToken: token,
        platform: platform,
      );
      result.fold(
        (failure) {
          if (failure is UnauthorizedFailure || failure.statusCode == 401) {
            _isUnauthorized = true;
          }
        },
        (_) {},
      );
    } catch (_) {
      // Silent background update - ignore non-fatal exceptions
    }
  }

  Future<void> _updateLocationSilently({
    double? lat,
    double? lng,
  }) async {
    if (_isUnauthorized) return;
    try {
      double? targetLat = lat;
      double? targetLng = lng;

      if (targetLat == null || targetLng == null) {
        final position = await locationService.getCurrentPosition();
        if (position != null) {
          targetLat = position.latitude;
          targetLng = position.longitude;
        }
      }

      if (targetLat == null || targetLng == null || _isUnauthorized) {
        // Permission denied or position unavailable; safely ignore
        return;
      }

      final result = await homeRepository.updateLocation(
        lat: targetLat,
        lng: targetLng,
      );
      result.fold(
        (failure) {
          if (failure is UnauthorizedFailure || failure.statusCode == 401) {
            _isUnauthorized = true;
          }
        },
        (updatedDriver) {
          if (_isUnauthorized) return;
          // If state is not currently in another loading transition, keep driver model updated
          if (state is! HomeAvailabilityLoading) {
            emit(HomeLoaded(
              isOnline: updatedDriver.isOnline,
              driver: updatedDriver,
            ));
          }
        },
      );
    } catch (_) {
      // Silent background update - ignore non-fatal exceptions
    }
  }

  /// Toggles driver availability (online / offline) with loading, success, and error states
  Future<void> toggleAvailability(bool targetOnline) async {
    if (_isUnauthorized) return;

    final currentOnline = state.isOnline;
    final currentDriver = state.driver;

    emit(HomeAvailabilityLoading(
      isOnline: currentOnline,
      driver: currentDriver,
      targetOnline: targetOnline,
    ));

    final result =
        await homeRepository.updateAvailability(isOnline: targetOnline);

    if (_isUnauthorized) return;

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure || failure.statusCode == 401) {
          _isUnauthorized = true;
          return;
        }
        String errorMsg = failure.message;
        if (targetOnline && (failure.statusCode == 422 || failure is ValidationFailure)) {
          if (errorMsg.isEmpty ||
              errorMsg.contains('إنهاء') ||
              errorMsg.contains('وردية') ||
              errorMsg.contains('ended') ||
              errorMsg.contains('shift')) {
            errorMsg = 'لقد قمت بإنهاء ورديتك اليوم، لا يمكنك العودة للعمل حتى الغد';
          }
        }
        emit(HomeAvailabilityError(
          isOnline: currentOnline,
          driver: currentDriver,
          message: errorMsg,
        ));
      },
      (updatedDriver) {
        emit(HomeAvailabilitySuccess(
          isOnline: updatedDriver.isOnline,
          driver: updatedDriver,
          message: 'تم تحديث حالة التواجد بنجاح',
        ));
      },
    );
  }

  /// Updates driver data directly in Home state
  void updateDriver(DriverModel updatedDriver) {
    emit(HomeLoaded(
      isOnline: updatedDriver.isOnline,
      driver: updatedDriver,
    ));
  }

  @override
  Future<void> close() {
    _unauthorizedSubscription?.cancel();
    _blockedSubscription?.cancel();
    _unblockedSubscription?.cancel();
    return super.close();
  }
}
