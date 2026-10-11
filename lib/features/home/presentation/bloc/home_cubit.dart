import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/device_id_helper.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final SharedPreferences sharedPreferences;

  HomeCubit({
    required this.homeRepository,
    required this.sharedPreferences,
  }) : super(const HomeInitial());

  /// Initializes home screen silently:
  /// 1. Reads cached driver / online status and emits [HomeLoaded].
  /// 2. Silently updates FCM token.
  /// 3. Silently updates current device location.
  Future<void> initHome({
    String? fcmToken,
    double defaultLat = 30.0444,
    double defaultLng = 31.2357,
  }) async {
    // 1. Load initial driver & online status from local cache
    final cachedDriver = await homeRepository.getCachedDriver();
    final isOnline =
        cachedDriver?.isOnline ?? await homeRepository.getCachedOnlineStatus();
    emit(HomeLoaded(isOnline: isOnline, driver: cachedDriver));

    // 2. Silently update FCM token & location in background
    await Future.wait([
      _updateFcmSilently(fcmToken: fcmToken),
      _updateLocationSilently(lat: defaultLat, lng: defaultLng),
    ]);
  }

  Future<void> _updateFcmSilently({String? fcmToken}) async {
    try {
      final deviceId = await DeviceIdHelper.getDeviceId(sharedPreferences);
      final platform =
          Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'flutter';
      final token = fcmToken ?? 'mock_fcm_token_delivery_app';

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
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await homeRepository.updateLocation(lat: lat, lng: lng);
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
