import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/error/exceptions.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/network/api_response.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/home/data/datasources/home_local_datasource.dart';
import 'package:delivery_app_project/features/home/data/datasources/home_remote_datasource.dart';
import 'package:delivery_app_project/features/home/data/repositories/home_repository_impl.dart';

class FakeHomeLocalDataSource implements HomeLocalDataSource {
  bool cachedOnline = false;

  @override
  Future<void> cacheOnlineStatus(bool isOnline) async {
    cachedOnline = isOnline;
  }

  @override
  bool getOnlineStatus() => cachedOnline;

  @override
  Future<void> cacheStats(Map<String, dynamic> stats) async {}

  @override
  Map<String, dynamic> getCachedStats() => {};
}

class FakeAuthLocalDataSourceForHome implements AuthLocalDataSource {
  DriverModel? savedDriver;

  @override
  Future<DriverModel?> getDriver() async => savedDriver;

  @override
  Future<void> saveDriver(DriverModel driver) async {
    savedDriver = driver;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
  @override
  Future<void> clearRegistrationToken() async {}
  @override
  Future<void> clearSession() async {}
  @override
  Future<void> clearTokens() async {}
  @override
  Future<String> getDriverId() async => '';
  @override
  Future<String> getRefreshToken() async => '';
  @override
  Future<String?> getRegistrationToken() async => null;
  @override
  Future<String?> getToken() async => 'test_token';
  @override
  Future<void> saveDriverId(String driverId) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveRegistrationToken(String token) async {}
  @override
  Future<void> saveToken(String token) async {}
}

class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  Exception? updateAvailabilityException;
  ApiResponse<Map<String, dynamic>>? updateAvailabilityResponse;

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateAvailability({
    required bool isOnline,
  }) async {
    if (updateAvailabilityException != null) {
      throw updateAvailabilityException!;
    }
    return updateAvailabilityResponse ??
        ApiResponse<Map<String, dynamic>>(
          status: 200,
          msg: 'تم تحديث حالة الشيفت بنجاح.',
          data: {
            'delivery': {
              'id': 1,
              'is_online': isOnline,
              'is_busy': false,
              'can_accept_orders': isOnline,
            }
          },
        );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateLocation({required double lat, required double lng}) async => throw UnimplementedError();
  @override
  Future<ApiResponse<void>> updateFcmToken({required String deviceId, required String fcmToken, String? platform}) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> bookShift(Map<String, dynamic> body) async => throw UnimplementedError();
  @override
  Future<List<dynamic>> getShifts() async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getTodayStats() async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> toggleOnlineStatus(bool isOnline) async => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeHomeRemoteDataSource fakeRemoteDataSource;
  late FakeAuthLocalDataSourceForHome fakeAuthLocalDataSource;
  late FakeHomeLocalDataSource fakeHomeLocalDataSource;
  late SharedPreferences sharedPreferences;
  late HomeRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    fakeRemoteDataSource = FakeHomeRemoteDataSource();
    fakeAuthLocalDataSource = FakeAuthLocalDataSourceForHome();
    fakeHomeLocalDataSource = FakeHomeLocalDataSource();

    fakeAuthLocalDataSource.savedDriver = const DriverModel(
      id: 1,
      name: 'Driver Ahmed',
      phone: '01011112222',
      isOnline: false,
      isBusy: false,
      canAcceptOrders: false,
    );

    repository = HomeRepositoryImpl(
      remoteDataSource: fakeRemoteDataSource,
      authLocalDataSource: fakeAuthLocalDataSource,
      homeLocalDataSource: fakeHomeLocalDataSource,
      sharedPreferences: sharedPreferences,
    );
  });

  group('HomeRepositoryImpl.updateAvailability Tests', () {
    test('on 200 OK (check-in): updates is_online, is_busy, and can_accept_orders from data.delivery', () async {
      fakeRemoteDataSource.updateAvailabilityResponse = ApiResponse<Map<String, dynamic>>(
        status: 200,
        msg: 'تم تحديث حالة الشيفت بنجاح.',
        data: {
          'delivery': {
            'id': 1,
            'is_online': true,
            'is_busy': false,
            'can_accept_orders': true,
          }
        },
      );

      final result = await repository.updateAvailability(isOnline: true);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (driver) {
          expect(driver.isOnline, isTrue);
          expect(driver.isBusy, isFalse);
          expect(driver.canAcceptOrders, isTrue);
        },
      );

      // Verify cached in both local data sources
      expect(fakeAuthLocalDataSource.savedDriver?.isOnline, isTrue);
      expect(fakeAuthLocalDataSource.savedDriver?.canAcceptOrders, isTrue);
      expect(fakeHomeLocalDataSource.cachedOnline, isTrue);
    });

    test('on 200 OK (check-out): updates is_online: false, can_accept_orders: false', () async {
      fakeAuthLocalDataSource.savedDriver = const DriverModel(
        id: 1,
        name: 'Driver Ahmed',
        phone: '01011112222',
        isOnline: true,
        isBusy: false,
        canAcceptOrders: true,
      );

      fakeRemoteDataSource.updateAvailabilityResponse = ApiResponse<Map<String, dynamic>>(
        status: 200,
        msg: 'تم تحديث حالة الشيفت بنجاح.',
        data: {
          'delivery': {
            'id': 1,
            'is_online': false,
            'is_busy': false,
            'can_accept_orders': false,
          }
        },
      );

      final result = await repository.updateAvailability(isOnline: false);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right'),
        (driver) {
          expect(driver.isOnline, isFalse);
          expect(driver.isBusy, isFalse);
          expect(driver.canAcceptOrders, isFalse);
        },
      );

      expect(fakeAuthLocalDataSource.savedDriver?.isOnline, isFalse);
      expect(fakeHomeLocalDataSource.cachedOnline, isFalse);
    });

    test('on 422 ValidationException: returns ValidationFailure with server msg', () async {
      fakeRemoteDataSource.updateAvailabilityException = const ValidationException(
        'لا يمكنك بدء الشيفت بدون موعد عمل محجوز لهذا اليوم.',
      );

      final result = await repository.updateAvailability(isOnline: true);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.statusCode, 422);
          expect(failure.message, 'لا يمكنك بدء الشيفت بدون موعد عمل محجوز لهذا اليوم.');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('on 403 ForbiddenException: returns ForbiddenFailure with server msg', () async {
      fakeRemoteDataSource.updateAvailabilityException = const ForbiddenException(
        'This account has been blocked.',
      );

      final result = await repository.updateAvailability(isOnline: true);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ForbiddenFailure>());
          expect(failure.statusCode, 403);
          expect(failure.message, 'This account has been blocked.');
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}
