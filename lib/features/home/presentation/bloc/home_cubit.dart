import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/device_id_helper.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final SharedPreferences sharedPreferences;
  final LocationService locationService;
  final NotificationService notificationService;

  HomeCubit({
    required this.homeRepository,
    required this.sharedPreferences,
    LocationService? locationService,
    NotificationService? notificationService,
  })  : locationService = locationService ?? LocationServiceImpl(),
        notificationService = notificationService ?? NotificationServiceImpl(),
        super(const HomeInitial());

  /// Initializes home screen silently:
  /// 1. Reads cached driver / online status and emits [HomeLoaded].
  /// 2. Silently updates FCM token from real device.
  /// 3. Silently updates current device location from GPS.
  Future<void> initHome({
    String? fcmToken,
    double? lat,
    double? lng,
  }) async {
    // 1. Load initial driver & online status from local cache
    final cachedDriver = await homeRepository.getCachedDriver();
    final isOnline =
        cachedDriver?.isOnline ?? await homeRepository.getCachedOnlineStatus();
    emit(HomeLoaded(isOnline: isOnline, driver: cachedDriver));

    // 2. Silently update FCM token & location in background
    await Future.wait([
      _updateFcmSilently(fcmToken: fcmToken),
      _updateLocationSilently(lat: lat, lng: lng),
    ]);
  }

  Future<void> _updateFcmSilently({String? fcmToken}) async {
    try {
      final token = fcmToken ?? await notificationService.getFcmToken();
      if (token == null || token.isEmpty) {
        // Permission denied or unavailable; safely ignore
        return;
      }

      final deviceId = await DeviceIdHelper.getDeviceId(sharedPreferences);
      final platform =
          Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'flutter';

      await homeRepository.updateFcmToken(
        deviceId: deviceId,
        fcmToken: token,
        platform: platform,
      );
    } catch (_) {
      // Silent background update - ignore non-fatal exceptions
    }
  }

  Future<void> _updateLocationSilently({
    double? lat,
    double? lng,
  }) async {
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

      if (targetLat == null || targetLng == null) {
        // Permission denied or position unavailable; safely ignore
        return;
      }

      final result = await homeRepository.updateLocation(
        lat: targetLat,
        lng: targetLng,
      );
      result.fold(
        (_) {},
        (updatedDriver) {
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
    final currentOnline = state.isOnline;
    final currentDriver = state.driver;

    emit(HomeAvailabilityLoading(
      isOnline: currentOnline,
      driver: currentDriver,
      targetOnline: targetOnline,
    ));

    final result =
        await homeRepository.updateAvailability(isOnline: targetOnline);

    result.fold(
      (failure) {
        emit(HomeAvailabilityError(
          isOnline: currentOnline,
          driver: currentDriver,
          message: failure.message,
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
}
