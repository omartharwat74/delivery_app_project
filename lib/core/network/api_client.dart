import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import 'api_response.dart';
import 'app_interceptor.dart';
import 'auth_event_bus.dart';
import 'error_parser.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    required this.dio,
    required AuthLocalDataSource localDataSource,
    required SharedPreferences sharedPreferences,
    required AuthEventBus authEventBus,
  }) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = ApiConstants.timeout;
    dio.options.receiveTimeout = ApiConstants.timeout;

    dio.interceptors.add(
      AppInterceptor(
        localDataSource: localDataSource,
        sharedPreferences: sharedPreferences,
        authEventBus: authEventBus,
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }

  // -------------------------------------------------------------
  // Typed ApiResponse Methods
  // -------------------------------------------------------------

  Future<ApiResponse<T>> getResponse<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      return _parseApiResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<ApiResponse<T>> postResponse<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: body,
        queryParameters: queryParams,
      );
      return _parseApiResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<ApiResponse<T>> putResponse<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: body,
        queryParameters: queryParams,
      );
      return _parseApiResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<ApiResponse<T>> patchResponse<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParams,
      );
      return _parseApiResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<ApiResponse<T>> deleteResponse<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParams,
      );
      return _parseApiResponse<T>(response.data, fromJson);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  // -------------------------------------------------------------
  // Backwards-Compatible Map<String, dynamic> Methods
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final response = await dio.post(endpoint, data: body);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final response = await dio.put(endpoint, data: body);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final response = await dio.patch(endpoint, data: body);
      return _extractData(response.data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      await dio.delete(endpoint);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  Future<Map<String, dynamic>> postMultipartFile(
    String endpoint, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? additionalQuery,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await dio.post(
        endpoint,
        data: formData,
        queryParameters: additionalQuery,
      );
      return _extractData(response.data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e);
    }
  }

  ApiResponse<T> _parseApiResponse<T>(
    dynamic data,
    T Function(dynamic data)? fromJson,
  ) {
    if (data is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(data, fromJson);
    }
    return ApiResponse<T>(
      status: 200,
      msg: '',
      data: fromJson != null ? fromJson(data) : data as T?,
    );
  }

  Map<String, dynamic> _extractData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data == null || data.toString().isEmpty) return {};
    return {'data': data};
  }
}
