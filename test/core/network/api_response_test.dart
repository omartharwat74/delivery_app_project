import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/network/api_response.dart';

void main() {
  group('ApiResponse Model Tests', () {
    test('should parse successful JSON with data object', () {
      final json = {
        'status': 200,
        'msg': 'تمت العملية بنجاح',
        'data': {'id': 1, 'name': 'Driver'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.status, 200);
      expect(response.msg, 'تمت العملية بنجاح');
      expect(response.isSuccess, isTrue);
      expect(response.data?['name'], 'Driver');
    });

    test('should parse 422 error JSON with empty list data', () {
      final json = {
        'status': 422,
        'msg': 'طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.',
        'data': [],
      };

      final response = ApiResponse<dynamic>.fromJson(json);

      expect(response.status, 422);
      expect(response.msg, 'طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.');
      expect(response.isSuccess, isFalse);
    });

    test('should serialize to JSON correctly', () {
      const response = ApiResponse<String>(
        status: 200,
        msg: 'Success',
        data: 'token_123',
      );

      final json = response.toJson((val) => val);

      expect(json['status'], 200);
      expect(json['msg'], 'Success');
      expect(json['data'], 'token_123');
    });
  });
}
