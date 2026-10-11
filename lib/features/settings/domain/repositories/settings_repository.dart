import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/data/models/driver_model.dart';

abstract class SettingsRepository {
  /// Returns locally cached DriverModel
  Future<DriverModel?> getCachedDriver();

  /// Toggles push notifications on the server and caches the updated driver
  Future<Either<Failure, DriverModel>> updateNotifications({required bool isNotify});

  /// Sends OTP to the driver's current registered phone
  Future<Either<Failure, Map<String, dynamic>>> sendCurrentOtp();

  /// Verifies OTP for the current phone, returning phone_change_token
  Future<Either<Failure, String>> verifyCurrentOtp({required String otp});

  /// Sends OTP to the new phone number using phone_change_token
  Future<Either<Failure, Map<String, dynamic>>> sendNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
  });

  /// Verifies OTP for the new phone, updates driver locally, and returns updated DriverModel
  Future<Either<Failure, DriverModel>> verifyNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
    required String otp,
  });
}
