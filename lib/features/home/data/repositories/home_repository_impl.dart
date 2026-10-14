import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/device_id_helper.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/models/driver_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final HomeLocalDataSource homeLocalDataSource;
  final SharedPreferences sharedPreferences;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
    required this.homeLocalDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<DriverModel?> getCachedDriver() async {
    return authLocalDataSource.getDriver();
  }

  @override
  Future<bool> getCachedOnlineStatus() async {
    final driver = await authLocalDataSource.getDriver();
    if (driver != null) return driver.isOnline;
    return homeLocalDataSource.getOnlineStatus();
  }

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String deviceId,
    required String fcmToken,
    String? platform,
  }) async {
    try {
      final effectiveDeviceId = deviceId.isNotEmpty
          ? deviceId
          : await DeviceIdHelper.getDeviceId(sharedPreferences);

      final effectivePlatform = platform ??
          (Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'flutter');

      await remoteDataSource.updateFcmToken(
        deviceId: effectiveDeviceId,
        fcmToken: fcmToken,
        platform: effectivePlatform,
      );
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, DriverModel>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await remoteDataSource.updateLocation(lat: lat, lng: lng);
      final data = response.data;

      final cachedDriver = await authLocalDataSource.getDriver();
      DriverModel updatedDriver;
      if (data != null && data.isNotEmpty) {
        final deliveryMap = data['delivery'] is Map<String, dynamic>
            ? data['delivery'] as Map<String, dynamic>
            : data;
        if (cachedDriver != null) {
          updatedDriver = cachedDriver.copyWith(
            currentLat: (deliveryMap['current_lat'] as num?)?.toDouble() ?? lat,
            currentLng: (deliveryMap['current_lng'] as num?)?.toDouble() ?? lng,
          );
        } else {
          updatedDriver = DriverModel.fromJson(deliveryMap);
        }
      } else if (cachedDriver != null) {
        updatedDriver = cachedDriver.copyWith(currentLat: lat, currentLng: lng);
      } else {
        updatedDriver = DriverModel(
          id: 0,
          name: '',
          phone: '',
          currentLat: lat,
          currentLng: lng,
        );
      }

      await authLocalDataSource.saveDriver(updatedDriver);
      return Right(updatedDriver);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, DriverModel>> updateAvailability({
    required bool isOnline,
  }) async {
    try {
      final response = await remoteDataSource.updateAvailability(
        isOnline: isOnline,
      );
      final data = response.data;

      final cachedDriver = await authLocalDataSource.getDriver();
      DriverModel updatedDriver;
      if (data != null && data.isNotEmpty) {
        final deliveryMap = data['delivery'] is Map<String, dynamic>
            ? data['delivery'] as Map<String, dynamic>
            : data;
        final newIsOnline = deliveryMap['is_online'] as bool? ?? isOnline;
        final newIsBusy = deliveryMap['is_busy'] as bool? ??
            (cachedDriver?.isBusy ?? false);
        final newCanAcceptOrders = deliveryMap['can_accept_orders'] as bool? ??
            (newIsOnline && !newIsBusy);

        if (cachedDriver != null) {
          updatedDriver = cachedDriver.copyWith(
            isOnline: newIsOnline,
            isBusy: newIsBusy,
            canAcceptOrders: newCanAcceptOrders,
          );
        } else {
          updatedDriver = DriverModel.fromJson(deliveryMap).copyWith(
            isOnline: newIsOnline,
            isBusy: newIsBusy,
            canAcceptOrders: newCanAcceptOrders,
          );
        }
      } else if (cachedDriver != null) {
        updatedDriver = cachedDriver.copyWith(
          isOnline: isOnline,
          canAcceptOrders: isOnline,
        );
      } else {
        updatedDriver = DriverModel(
          id: 0,
          name: '',
          phone: '',
          isOnline: isOnline,
          canAcceptOrders: isOnline,
        );
      }

      await authLocalDataSource.saveDriver(updatedDriver);
      await homeLocalDataSource.cacheOnlineStatus(updatedDriver.isOnline);
      return Right(updatedDriver);
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
