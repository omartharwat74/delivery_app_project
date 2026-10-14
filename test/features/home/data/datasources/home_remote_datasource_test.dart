import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/constants/api_constants.dart';
import 'package:delivery_app_project/core/network/api_client.dart';
import 'package:delivery_app_project/core/network/api_response.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/home/data/datasources/home_remote_datasource.dart';

class DummyAuthLocalDataSource implements AuthLocalDataSource {
  @override
  Future<void> clearRegistrationToken() async {}
  @override
  Future<void> clearSession() async {}
  @override
  Future<void> clearTokens() async {}
  @override
  Future<DriverModel?> getDriver() async => null;
  @override
  Future<String> getDriverId() async => '';
  @override
  Future<String> getRefreshToken() async => '';
  @override
  Future<String?> getRegistrationToken() async => null;
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> saveDriver(DriverModel driver) async {}
  @override
  Future<void> saveDriverId(String driverId) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveRegistrationToken(String token) async {}
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
}

class FakeApiClient extends ApiClient {
  String? lastEndpoint;
  dynamic lastBody;
  ApiResponse<Map<String, dynamic>>? responseToReturn;

  FakeApiClient({required super.sharedPreferences})
      : super(
          dio: Dio(),
          localDataSource: DummyAuthLocalDataSource(),
          authEventBus: AuthEventBus(),
        );

  @override
  Future<ApiResponse<T>> patchResponse<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    lastEndpoint = endpoint;
    lastBody = body;
    final res = responseToReturn ??
        ApiResponse<Map<String, dynamic>>(
          status: 200,
          msg: 'تم تحديث حالة الشيفت بنجاح.',
          data: {
            'delivery': {
              'id': 1,
              'is_online': body is Map ? body['is_online'] : true,
              'is_busy': false,
              'can_accept_orders': body is Map ? body['is_online'] : true,
            }
          },
        );
    final parsedData = fromJson != null ? fromJson(res.data) : res.data as T;
    return ApiResponse<T>(
      status: res.status,
      msg: res.msg,
      data: parsedData,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeApiClient fakeClient;
  late HomeRemoteDataSourceImpl remoteDataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    fakeClient = FakeApiClient(sharedPreferences: sharedPrefs);
    remoteDataSource = HomeRemoteDataSourceImpl(fakeClient);
  });

  group('HomeRemoteDataSource.updateAvailability Tests', () {
    test('endpoint is /attendance/availability (not the deprecated /auth/availability)', () {
      expect(ApiConstants.availability, '/attendance/availability');
    });

    test('updateAvailability(true) sends PATCH to /attendance/availability with {"is_online": true} and no client time', () async {
      await remoteDataSource.updateAvailability(isOnline: true);

      expect(fakeClient.lastEndpoint, '/attendance/availability');
      expect(fakeClient.lastBody, equals({'is_online': true}));
      // Verify no timestamp or client time is included
      final body = fakeClient.lastBody as Map<String, dynamic>;
      expect(body.containsKey('time'), isFalse);
      expect(body.containsKey('timestamp'), isFalse);
    });

    test('updateAvailability(false) sends PATCH to /attendance/availability with {"is_online": false}', () async {
      await remoteDataSource.updateAvailability(isOnline: false);

      expect(fakeClient.lastEndpoint, '/attendance/availability');
      expect(fakeClient.lastBody, equals({'is_online': false}));
    });
  });
}
