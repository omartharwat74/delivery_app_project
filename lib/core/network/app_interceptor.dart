import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import 'auth_event_bus.dart';

class AppInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;
  final AuthEventBus authEventBus;

  bool _isHandlingUnauthorized = false;

  AppInterceptor({
    required this.localDataSource,
    required this.sharedPreferences,
    required this.authEventBus,
  });

  bool get isHandlingUnauthorized => _isHandlingUnauthorized;

  void resetUnauthorizedLock() {
    _isHandlingUnauthorized = false;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Accept: application/json always
    options.headers['Accept'] = 'application/json';

    // 2. local: ar or en based on app language
    final savedLocale = sharedPreferences.getString('driver_app_locale');
    final langCode = (savedLocale == 'en') ? 'en' : 'ar';
    options.headers['local'] = langCode;

    // 3. Content-Type: do NOT set manually for multipart FormData
    if (options.data is FormData) {
      options.headers.remove('Content-Type');
    } else {
      options.headers['Content-Type'] ??= 'application/json';
    }

    // 4. Authorization: Bearer <delivery_token> (only when token is present)
    try {
      final token = await localDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        // Reset lock when an authenticated request is initiated with a valid token
        _isHandlingUnauthorized = false;
      }
    } catch (_) {
      // No token found, proceed unauthenticated
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Error Handling: In case of 401, trigger logout event and clear token from device
    // Prevent duplicate logout if multiple requests fail at the same moment
    if (err.response?.statusCode == 401) {
      if (!_isHandlingUnauthorized) {
        _isHandlingUnauthorized = true;
        try {
          await localDataSource.clearSession();
        } catch (_) {}
        authEventBus.emitUnauthorized();
      }
    }

    return handler.next(err);
  }
}
