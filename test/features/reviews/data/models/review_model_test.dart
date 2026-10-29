import 'package:delivery_app_project/features/reviews/data/models/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewModel JSON parsing', () {
    test('parses order_id, rating, comment, and nested user name correctly', () {
      final json = {
        'id': 12,
        'order_id': 105,
        'rating': 4.5,
        'comment': 'توصيل سريع وممتاز',
        'is_reported': false,
        'created_at': '2026-10-29T18:00:00Z',
        'user': {'name': 'سارة محمود'},
      };

      final model = ReviewModel.fromJson(json);

      expect(model.id, 12);
      expect(model.orderId, 105);
      expect(model.rating, 4.5);
      expect(model.comment, 'توصيل سريع وممتاز');
      expect(model.user.name, 'سارة محمود');
    });

    test('falls back to customer_name or user_name if user object is not present', () {
      final json = {
        'id': 13,
        'order_id': 'ORD-99',
        'rating': 5,
        'comment': 'سائق محترم جداً',
        'customer_name': 'يوسف خالد',
      };

      final model = ReviewModel.fromJson(json);

      expect(model.id, 13);
      expect(model.orderId, 'ORD-99');
      expect(model.rating, 5);
      expect(model.user.name, 'يوسف خالد');
    });
  });
}
