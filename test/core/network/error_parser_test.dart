import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/exceptions.dart';
import 'package:delivery_app_project/core/network/error_parser.dart';

void main() {
  group('ErrorParser Tests', () {
    test('should parse 401 into UnauthorizedException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
          data: {
            'status': 401,
            'msg': 'غير مصرح. يرجى تسجيل الدخول',
            'data': [],
          },
        ),
      );

      final exception = ErrorParser.parse(dioError);

      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, 'غير مصرح. يرجى تسجيل الدخول');
      expect(exception.statusCode, 401);
    });

    test('should parse 403 into ForbiddenException with block message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
          statusCode: 403,
          data: {
            'status': 403,
            'msg': 'تم حظر الحساب',
            'data': [],
          },
        ),
      );

      final exception = ErrorParser.parse(dioError);

      expect(exception, isA<ForbiddenException>());
      expect(exception.message, 'تم حظر الحساب');
      expect(exception.statusCode, 403);
    });

    test('should parse 422 with validation Object into ValidationException with extracted field errors', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
          statusCode: 422,
          data: {
            'status': 422,
            'msg': 'The phone field is required.',
            'data': {
              'phone': ['The phone field is required.'],
              'national_id': ['The national id format is invalid.'],
            },
          },
        ),
      );

      final exception = ErrorParser.parse(dioError);

      expect(exception, isA<ValidationException>());
      final valEx = exception as ValidationException;
      expect(valEx.errors['phone']?.first, 'The phone field is required.');
      expect(valEx.errors['national_id']?.first, 'The national id format is invalid.');
      expect(valEx.message.contains('The phone field is required.'), isTrue);
    });

    test('should parse 422 with empty array data into ValidationException using msg', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/phone/verify-otp'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/phone/verify-otp'),
          statusCode: 422,
          data: {
            'status': 422,
            'msg': 'طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.',
            'data': [],
          },
        ),
      );

      final exception = ErrorParser.parse(dioError);

      expect(exception, isA<ValidationException>());
      expect(exception.message, 'طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.');
      expect((exception as ValidationException).errors.isEmpty, isTrue);
    });

    test('should parse connection error into NetworkException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/phone/send-otp'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ErrorParser.parse(dioError);

      expect(exception, isA<NetworkException>());
    });
  });
}
