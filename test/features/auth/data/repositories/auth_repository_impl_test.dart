import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/error/exceptions.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/network/api_response.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:delivery_app_project/features/auth/data/models/area_model.dart';
import 'package:delivery_app_project/features/auth/data/models/auth_response.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/auth/data/models/logout_request.dart';
import 'package:delivery_app_project/features/auth/data/models/register_driver_request.dart';
import 'package:delivery_app_project/features/auth/data/models/register_driver_response.dart';
import 'package:delivery_app_project/features/auth/data/models/send_otp_request.dart';
import 'package:delivery_app_project/features/auth/data/models/send_otp_response.dart';
import 'package:delivery_app_project/features/auth/data/models/shift_model.dart';
import 'package:delivery_app_project/features/auth/data/models/verify_otp_request.dart';
import 'package:delivery_app_project/features/auth/data/models/verify_otp_response.dart';
import 'package:delivery_app_project/features/auth/data/repositories/auth_repository_impl.dart';

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  int clearSessionCallCount = 0;
  String? savedToken;
  DriverModel? savedDriver;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount++;
    savedToken = null;
    savedDriver = null;
  }

  @override
  Future<String?> getToken() async => savedToken;

  @override
  Future<void> saveToken(String token) async {
    savedToken = token;
  }

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
  Future<void> clearTokens() async {}
  @override
  Future<String> getDriverId() async => '';
  @override
  Future<String> getRefreshToken() async => '';
  @override
  Future<String?> getRegistrationToken() async => null;
  @override
  Future<void> saveDriverId(String driverId) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveRegistrationToken(String token) async {}
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Exception? logoutException;
  int logoutCallCount = 0;
  LogoutRequest? lastLogoutRequest;

  @override
  Future<ApiResponse<void>> logout(LogoutRequest request) async {
    logoutCallCount++;
    lastLogoutRequest = request;
    if (logoutException != null) {
      throw logoutException!;
    }
    return ApiResponse<void>(status: 200, msg: 'تم تسجيل الخروج بنجاح', data: null);
  }

  @override
  Future<ApiResponse<DriverModel>> getMe() async => throw UnimplementedError();
  @override
  Future<ApiResponse<List<AreaModel>>> getAreas() async => throw UnimplementedError();
  @override
  Future<ApiResponse<List<ShiftModel>>> getShifts() async => throw UnimplementedError();
  @override
  Future<ApiResponse<RegisterDriverResponse>> registerDriver(RegisterDriverRequest request) async => throw UnimplementedError();
  @override
  Future<ApiResponse<SendOtpResponse>> sendOtp(SendOtpRequest request) async => throw UnimplementedError();
  @override
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request) async => throw UnimplementedError();
  @override
  Future<AuthResponse> refreshToken(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> sendDriverLoginOtp(String phone) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> uploadMedia(String filePath) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> verifyDriverLoginOtp(String phone, String otp) async => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthLocalDataSource fakeLocalDataSource;
  late FakeAuthRemoteDataSource fakeRemoteDataSource;
  late SharedPreferences sharedPreferences;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'delivery_app_device_id': 'test-device-uuid-123'});
    sharedPreferences = await SharedPreferences.getInstance();
    fakeLocalDataSource = FakeAuthLocalDataSource();
    fakeRemoteDataSource = FakeAuthRemoteDataSource();

    fakeLocalDataSource.savedToken = 'valid_driver_bearer_token';
    fakeLocalDataSource.savedDriver = const DriverModel(
      id: 10,
      name: 'Ahmed Ali',
      phone: '01011112222',
      isOnline: true,
      isBusy: true,
    );

    repository = AuthRepositoryImpl(
      localDataSource: fakeLocalDataSource,
      remoteDataSource: fakeRemoteDataSource,
      sharedPreferences: sharedPreferences,
    );
  });

  group('AuthRepositoryImpl.logout Tests', () {
    test('on 200 OK: sends device_id, clears session, and returns Right(null)', () async {
      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(fakeRemoteDataSource.logoutCallCount, 1);
      expect(fakeRemoteDataSource.lastLogoutRequest?.deviceId, 'test-device-uuid-123');
      expect(fakeLocalDataSource.clearSessionCallCount, 1);
      expect(fakeLocalDataSource.savedToken, isNull);
    });

    test('on 422 ValidationException (driver busy): does NOT clear session and returns Left(ValidationFailure)', () async {
      fakeRemoteDataSource.logoutException = const ValidationException(
        'لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.',
      );

      final result = await repository.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.statusCode, 422);
          expect(failure.message, 'لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.');
        },
        (_) => fail('Should have returned Left'),
      );

      // Crucial: token and session MUST NOT be cleared
      expect(fakeLocalDataSource.clearSessionCallCount, 0);
      expect(fakeLocalDataSource.savedToken, 'valid_driver_bearer_token');
      expect(fakeLocalDataSource.savedDriver?.name, 'Ahmed Ali');
    });

    test('on network timeout / unreachable server: still clears local session to avoid stuck state', () async {
      fakeRemoteDataSource.logoutException = const NetworkException('Connection timeout');

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      expect(fakeLocalDataSource.clearSessionCallCount, 1);
      expect(fakeLocalDataSource.savedToken, isNull);
    });
  });
}
