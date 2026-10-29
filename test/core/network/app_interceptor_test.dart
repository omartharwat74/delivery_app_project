import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/network/app_interceptor.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  int clearSessionCallCount = 0;
  String? tokenToReturn;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount++;
  }

  @override
  Future<String?> getToken() async => tokenToReturn;

  @override
  Future<void> clearRegistrationToken() async {}

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
  Future<void> saveDriver(DriverModel driver) async {}

  @override
  Future<void> saveDriverId(String driverId) async {}

  @override
  Future<void> saveRefreshToken(String token) async {}

  @override
  Future<void> saveRegistrationToken(String token) async {}

  @override
  Future<void> saveToken(String token) async {
    tokenToReturn = token;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
}

class FakeRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? optionsPassed;

  @override
  void next(RequestOptions requestOptions) {
    optionsPassed = requestOptions;
  }
}

class FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? errorPassed;

  @override
  void next(DioException err) {
    errorPassed = err;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthLocalDataSource localDataSource;
  late SharedPreferences prefs;
  late AuthEventBus authEventBus;
  late AppInterceptor interceptor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'driver_app_locale': 'ar'});
    prefs = await SharedPreferences.getInstance();
    localDataSource = FakeAuthLocalDataSource();
    authEventBus = AuthEventBus();
    interceptor = AppInterceptor(
      localDataSource: localDataSource,
      sharedPreferences: prefs,
      authEventBus: authEventBus,
    );
  });

  group('AppInterceptor 401 Unauthorized Tests', () {
    test('clears session and emits unauthorized when statusCode is 401', () async {
      int unauthorizedEventsCount = 0;
      final sub = authEventBus.onUnauthorized.listen((_) {
        unauthorizedEventsCount++;
      });

      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
        ),
      );

      final handler = FakeErrorInterceptorHandler();
      interceptor.onError(dioException, handler);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(localDataSource.clearSessionCallCount, 1);
      expect(unauthorizedEventsCount, 1);
      expect(interceptor.isHandlingUnauthorized, isTrue);
      expect(handler.errorPassed, dioException);

      await sub.cancel();
    });

    test('prevents duplicate logout when multiple concurrent requests fail with 401', () async {
      int unauthorizedEventsCount = 0;
      final sub = authEventBus.onUnauthorized.listen((_) {
        unauthorizedEventsCount++;
      });

      final err1 = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
        ),
      );

      final err2 = DioException(
        requestOptions: RequestOptions(path: '/auth/location'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/location'),
          statusCode: 401,
        ),
      );

      final handler1 = FakeErrorInterceptorHandler();
      final handler2 = FakeErrorInterceptorHandler();

      // Trigger both simultaneously
      interceptor.onError(err1, handler1);
      interceptor.onError(err2, handler2);

      await Future<void>.delayed(const Duration(milliseconds: 30));

      // Should only clear session and emit once!
      expect(localDataSource.clearSessionCallCount, 1);
      expect(unauthorizedEventsCount, 1);

      await sub.cancel();
    });

    test('resets unauthorized lock when new authenticated request is made in onRequest', () async {
      // First, simulate 401 lock
      final err = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
        ),
      );
      interceptor.onError(err, FakeErrorInterceptorHandler());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(interceptor.isHandlingUnauthorized, isTrue);

      // Now user logs in again and makes a new authenticated request
      localDataSource.tokenToReturn = 'new_login_token_abc';
      final options = RequestOptions(path: '/auth/me');
      final handler = FakeRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(options.headers['Authorization'], 'Bearer new_login_token_abc');
      expect(interceptor.isHandlingUnauthorized, isFalse);
    });

    test('does not clear session or emit unauthorized for non-401 errors', () async {
      int unauthorizedEventsCount = 0;
      final sub = authEventBus.onUnauthorized.listen((_) {
        unauthorizedEventsCount++;
      });

      final dioException500 = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 500,
        ),
      );

      final handler = FakeErrorInterceptorHandler();
      interceptor.onError(dioException500, handler);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(localDataSource.clearSessionCallCount, 0);
      expect(unauthorizedEventsCount, 0);
      expect(interceptor.isHandlingUnauthorized, isFalse);

      await sub.cancel();
    });

    test('retains session and emits accountBlocked when statusCode is 403', () async {
      String? receivedMessage;
      final sub = authEventBus.onAccountBlocked.listen((msg) {
        receivedMessage = msg;
      });

      final dioException403 = DioException(
        requestOptions: RequestOptions(path: '/orders/offer'),
        response: Response(
          requestOptions: RequestOptions(path: '/orders/offer'),
          statusCode: 403,
          data: {'msg': 'حسابك محظور. تواصل مع الدعم'},
        ),
      );

      final handler = FakeErrorInterceptorHandler();
      interceptor.onError(dioException403, handler);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(localDataSource.clearSessionCallCount, 0);
      expect(receivedMessage, 'حسابك محظور. تواصل مع الدعم');
      expect(interceptor.isHandlingBlocked, isTrue);

      await sub.cancel();
    });
  });
}
