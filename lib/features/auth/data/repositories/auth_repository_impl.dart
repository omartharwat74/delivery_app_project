import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/device_id_helper.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/driver_model.dart';
import '../models/logout_request.dart';
import '../models/register_driver_request.dart';
import '../models/register_driver_response.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../models/auth_response.dart';
import '../../domain/entities/driver_registration.dart';
import '../../domain/entities/driver_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<bool> get isLoggedIn async {
    try {
      final token = await localDataSource.getToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return localDataSource.getToken();
  }

  @override
  Future<String?> getRegistrationToken() async {
    return localDataSource.getRegistrationToken();
  }

  @override
  Future<void> saveRegistrationToken(String token) async {
    await localDataSource.saveRegistrationToken(token);
  }

  @override
  Future<DriverModel?> getCachedDriver() async {
    return localDataSource.getDriver();
  }

  @override
  Future<Either<Failure, void>> clearSession() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendOtpResponse>> sendOtp(String phone) async {
    try {
      final response = await remoteDataSource.sendOtp(
        SendOtpRequest(phone: phone),
      );
      if (response.data != null) {
        return Right(response.data!);
      }
      return Right(SendOtpResponse(status: 'otp_sent'));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final deviceId = await DeviceIdHelper.getDeviceId(sharedPreferences);
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'flutter';

      final request = VerifyOtpRequest(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        platform: platform,
        deviceName: '${Platform.operatingSystem} Device',
        appVersion: '1.0.0',
      );

      final response = await remoteDataSource.verifyOtp(request);
      final data = response.data;
      if (data == null) {
        return Left(ServerFailure(AppStrings.verificationDataUnavailable));
      }

      if (data.isAuthenticated && data.token != null && data.token!.isNotEmpty) {
        // Active driver: Save Sanctum Bearer token and driver profile
        await localDataSource.saveToken(data.token!);
        if (data.delivery != null) {
          await localDataSource.saveDriver(data.delivery!);
        }
        await localDataSource.clearRegistrationToken();
      } else if (data.isCompleteRegistration && data.registrationToken != null) {
        // New phone: Cache registration token for registration screen
        await localDataSource.saveRegistrationToken(data.registrationToken!);
      }

      return Right(data);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RegisterDriverResponse>> registerDriver(
    RegisterDriverRequest request,
  ) async {
    try {
      final response = await remoteDataSource.registerDriver(request);
      final data = response.data;
      if (data != null) {
        await localDataSource.clearRegistrationToken();
        return Right(data);
      }
      return Right(
        RegisterDriverResponse(
          status: 'pending_review',
          message: AppStrings.pendingReview,
        ),
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final deviceId = await DeviceIdHelper.getDeviceId(sharedPreferences);
      try {
        await remoteDataSource.logout(LogoutRequest(deviceId: deviceId));
      } catch (_) {
        // Even if remote server call fails, we always clear the local session
      }
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearSession();
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, DriverModel>> getMe() async {
    try {
      final response = await remoteDataSource.getMe();
      if (response.data != null) {
        await localDataSource.saveDriver(response.data!);
        return Right(response.data!);
      }
      return Left(ServerFailure(AppStrings.unableToFetchDriver));
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Backward compatibility methods
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, void>> sendDriverLoginOtp(String phone) async {
    final result = await sendOtp(phone);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyDriverLoginOtp(
    String phone,
    String otp,
  ) async {
    final result = await verifyOtp(phone: phone, otp: otp);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        return Right(
          AuthResponse(
            accessToken: data.token ?? '',
            refreshToken: '',
            tokenType: 'Bearer',
            userId: data.delivery?.id.toString() ?? '',
            phone: phone,
            firstName: data.delivery?.name ?? '',
            lastName: '',
            fullName: data.delivery?.name ?? '',
            role: 'driver',
            newUser: data.isCompleteRegistration,
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, DriverRegistration>> registerDriverLegacy(
    RegisterDriverParams params,
  ) async {
    return const Right(
      DriverRegistration(
        userId: '1',
        message: 'تم إرسال طلبك وهو قيد مراجعة الإدارة.',
      ),
    );
  }

  @override
  Future<String?> uploadMedia(String filePath) async {
    try {
      final res = await remoteDataSource.uploadMedia(filePath);
      return res['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    return const Right(
      AuthResponse(
        accessToken: '',
        refreshToken: '',
        tokenType: 'Bearer',
        userId: '',
        phone: '',
        firstName: '',
        lastName: '',
        fullName: '',
        role: 'driver',
        newUser: false,
      ),
    );
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = await localDataSource.getRefreshToken();
    return token.isNotEmpty ? token : null;
  }

  @override
  Future<Either<Failure, DriverSession?>> getCachedSession() async {
    final token = await localDataSource.getToken();
    final driverId = await localDataSource.getDriverId();
    if (token != null && token.isNotEmpty) {
      return Right(DriverSession(token: token, driverId: driverId));
    }
    return const Right(null);
  }

  // ---------------------------------------------------------------------------
  // Exception to Failure mapper
  // ---------------------------------------------------------------------------

  Failure _mapExceptionToFailure(dynamic error) {
    if (error is ValidationException) {
      return ValidationFailure(error.message, errors: error.errors);
    }
    if (error is ForbiddenException) {
      return ForbiddenFailure(error.message);
    }
    if (error is UnauthorizedException) {
      return UnauthorizedFailure(error.message);
    }
    if (error is NotFoundException) {
      return NotFoundFailure(error.message);
    }
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is ServerException) {
      return ServerFailure(error.message, statusCode: error.statusCode);
    }
    if (error is CacheException) {
      return CacheFailure(error.message);
    }
    return ServerFailure(error.toString());
  }
}
