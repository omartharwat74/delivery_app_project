import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../localization/app_strings.dart';

class ErrorParser {
  /// Parses DioException into the corresponding domain-level ApiException
  /// using bilingual fallback strings according to the active language.
  static ApiException parse(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(AppStrings.connectionError);
    }

    final response = e.response;
    if (response != null && response.data != null) {
      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        final statusCode = response.statusCode ?? (body['status'] as int?);
        final msg = body['msg']?.toString() ??
            body['message']?.toString() ??
            AppStrings.unexpectedError;
        final dynamic rawData = body['data'];

        if (statusCode == 401) {
          return UnauthorizedException(msg, rawData);
        }

        if (statusCode == 403) {
          // In 403, display the blocked message from msg
          return ForbiddenException(msg, data: rawData);
        }

        if (statusCode == 422) {
          // If data is an Object (Map), extract validation errors
          if (rawData is Map<String, dynamic> && rawData.isNotEmpty) {
            final Map<String, List<String>> errors = {};
            rawData.forEach((key, value) {
              if (value is List) {
                errors[key] = value.map((item) => item.toString()).toList();
              } else if (value != null) {
                errors[key] = [value.toString()];
              }
            });

            // Combine all field error messages cleanly
            final combinedErrors = errors.values
                .expand((list) => list)
                .where((str) => str.isNotEmpty)
                .join('\n');

            return ValidationException(
              combinedErrors.isNotEmpty ? combinedErrors : msg,
              errors: errors,
              data: rawData,
            );
          } else {
            // If data is empty (e.g. array [] or null), display the msg (e.g. "طلبك قيد المراجعة")
            return ValidationException(
              msg,
              errors: const {},
              data: rawData,
            );
          }
        }

        if (statusCode == 404) {
          return NotFoundException(msg, rawData);
        }

        return ServerException(
          msg,
          statusCode: statusCode,
          data: rawData,
        );
      }
    }

    final code = e.response?.statusCode;
    return ServerException(
      AppStrings.serverErrorWithCode(code),
      statusCode: code,
    );
  }
}
