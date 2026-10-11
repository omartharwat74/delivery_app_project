import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/models/driver_model.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<DriverModel?> getCachedDriver() async {
    return authLocalDataSource.getDriver();
  }

  @override
  Future<Either<Failure, DriverModel>> updateNotifications({
    required bool isNotify,
  }) async {
    try {
      final updatedDriver = await remoteDataSource.updateNotifications(
        isNotify: isNotify,
      );

      final current = await authLocalDataSource.getDriver();
      final merged = (current ?? updatedDriver).copyWith(
        isNotify: isNotify,
        name: updatedDriver.name.isNotEmpty ? updatedDriver.name : current?.name,
        phone: updatedDriver.phone.isNotEmpty ? updatedDriver.phone : current?.phone,
        email: updatedDriver.email ?? current?.email,
      );
      await authLocalDataSource.saveDriver(merged);

      return Right(merged);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendCurrentOtp() async {
    try {
      final result = await remoteDataSource.sendCurrentOtp();
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyCurrentOtp({required String otp}) async {
    try {
      final token = await remoteDataSource.verifyCurrentOtp(otp: otp);
      return Right(token);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
  }) async {
    try {
      final result = await remoteDataSource.sendNewPhoneOtp(
        phoneChangeToken: phoneChangeToken,
        newPhone: newPhone,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, DriverModel>> verifyNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
    required String otp,
  }) async {
    try {
      final updatedDriver = await remoteDataSource.verifyNewPhoneOtp(
        phoneChangeToken: phoneChangeToken,
        newPhone: newPhone,
        otp: otp,
      );

      final current = await authLocalDataSource.getDriver();
      final effectivePhone = updatedDriver.phone.isNotEmpty
          ? updatedDriver.phone
          : newPhone;

      final merged = (current ?? updatedDriver).copyWith(
        phone: effectivePhone,
        name: updatedDriver.name.isNotEmpty ? updatedDriver.name : current?.name,
        email: updatedDriver.email ?? current?.email,
        status: updatedDriver.status.isNotEmpty ? updatedDriver.status : current?.status,
      );
      await authLocalDataSource.saveDriver(merged);

      return Right(merged);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

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
