import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import 'auth_event_bus.dart';

class AppInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;
  final AuthEventBus authEventBus;

  bool _isHandlingUnauthorized = false;
  bool _isHandlingBlocked = false;

  AppInterceptor({
    required this.localDataSource,
    required this.sharedPreferences,
    required this.authEventBus,
  });

  bool get isHandlingUnauthorized => _isHandlingUnauthorized;
  bool get isHandlingBlocked => _isHandlingBlocked;

  void resetUnauthorizedLock() {
    _isHandlingUnauthorized = false;
    _isHandlingBlocked = false;
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
    // 1. In case of 401 Unauthorized, clear session and emit unauthorized
    if (err.response?.statusCode == 401) {
      if (!_isHandlingUnauthorized) {
        _isHandlingUnauthorized = true;
        try {
          await localDataSource.clearSession();
        } catch (_) {}
        authEventBus.emitUnauthorized();
      }
    }
    // 2. In case of 403 Forbidden / Blocked, do NOT clear session or logout.
    // The driver must stay logged into their session to contact support.
    else if (err.response?.statusCode == 403) {
      if (!_isHandlingBlocked) {
        _isHandlingBlocked = true;
        String? message;
        final data = err.response?.data;
        if (data is Map<String, dynamic> && data['msg'] != null) {
          message = data['msg'].toString();
        }
        authEventBus.emitAccountBlocked(message);
      }
    }

    return handler.next(err);
  }
}
