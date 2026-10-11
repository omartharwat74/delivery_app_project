import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/area_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/register_driver_request.dart';
import '../../data/models/register_driver_response.dart';
import '../../data/models/send_otp_response.dart';
import '../../data/models/verify_otp_response.dart';
import '../../data/models/auth_response.dart';
import '../entities/driver_registration.dart';
import '../entities/driver_session.dart';

class RegisterDriverParams {
  const RegisterDriverParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.nationalId,
    required this.profilePhotoUrl,
    required this.driverLicensePhotoUrl,
    required this.vehicleLicensePhotoUrl,
    required this.nationalIdPhotoUrl,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String vehicleType;
  final String vehicleNumber;
  final String nationalId;
  final String profilePhotoUrl;
  final String driverLicensePhotoUrl;
  final String vehicleLicensePhotoUrl;
  final String nationalIdPhotoUrl;
}

abstract class AuthRepository {
  Future<bool> get isLoggedIn;
  Future<String?> getAccessToken();
  Future<String?> getRegistrationToken();
  Future<void> saveRegistrationToken(String token);
  Future<DriverModel?> getCachedDriver();
  Future<Either<Failure, void>> clearSession();

  /// POST /auth/phone/send-otp
  Future<Either<Failure, SendOtpResponse>> sendOtp(String phone);

  /// POST /auth/phone/verify-otp
  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// POST /auth/register (multipart/form-data)
  Future<Either<Failure, RegisterDriverResponse>> registerDriver(
    RegisterDriverRequest request,
  );

  /// POST /auth/logout
  Future<Either<Failure, void>> logout();

  /// GET /auth/me
  Future<Either<Failure, DriverModel>> getMe();

  /// GET /lookups/areas
  Future<Either<Failure, List<AreaModel>>> getAreas();

  /// GET /lookups/shifts
  Future<Either<Failure, List<ShiftModel>>> getShifts();

  // Backward compatibility methods
  Future<Either<Failure, void>> sendDriverLoginOtp(String phone);
  Future<Either<Failure, AuthResponse>> verifyDriverLoginOtp(
    String phone,
    String otp,
  );
  Future<Either<Failure, DriverRegistration>> registerDriverLegacy(
    RegisterDriverParams params,
  );
  Future<String?> uploadMedia(String filePath);
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<Either<Failure, DriverSession?>> getCachedSession();
}
