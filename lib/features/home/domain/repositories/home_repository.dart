import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/data/models/driver_model.dart';

abstract class HomeRepository {
  /// PATCH /auth/update-fcm
  Future<Either<Failure, void>> updateFcmToken({
    required String deviceId,
    required String fcmToken,
    String? platform,
  });

  /// PATCH /auth/location
  Future<Either<Failure, DriverModel>> updateLocation({
    required double lat,
    required double lng,
  });

  /// PATCH /attendance/availability
  Future<Either<Failure, DriverModel>> updateAvailability({
    required bool isOnline,
    double? lat,
    double? lng,
  });

  /// Locally cached driver and online status
  Future<DriverModel?> getCachedDriver();
  Future<bool> getCachedOnlineStatus();
}
