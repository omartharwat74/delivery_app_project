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

    test('parses payload with null comment and integer rating safely', () {
      final json = {
        'id': 2,
        'order_id': 2,
        'rating': 1,
        'comment': null,
        'is_reported': false,
        'created_at': '2026-10-30 01:06:30',
        'user': {'id': 3, 'name': 'omar tharwat'},
      };

      final model = ReviewModel.fromJson(json);

      expect(model.id, 2);
      expect(model.orderId, 2);
      expect(model.rating, 1.0);
      expect(model.comment, '');
      expect(model.isReported, false);
      expect(model.user.name, 'omar tharwat');
    });
  });

  group('ReviewPaginatedResponse JSON parsing', () {
    test('parses items list and meta correctly from backend response format', () {
      final json = {
        'items': [
          {
            'id': 2,
            'order_id': 2,
            'rating': 1,
            'comment': null,
            'is_reported': false,
            'created_at': '2026-10-30 01:06:30',
            'user': {'id': 3, 'name': 'omar tharwat'},
          },
          {
            'id': 1,
            'order_id': 3,
            'rating': 5,
            'comment': 'محترم',
            'is_reported': false,
            'created_at': '2026-10-29 21:05:16',
            'user': {'id': 3, 'name': 'omar tharwat'},
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 10,
          'total': 2,
        },
      };

      final paginated = ReviewPaginatedResponse.fromJson(json);

      expect(paginated.reviews.length, 2);
      expect(paginated.currentPage, 1);
      expect(paginated.lastPage, 1);
      expect(paginated.total, 2);
      expect(paginated.reviews[0].id, 2);
      expect(paginated.reviews[0].rating, 1.0);
      expect(paginated.reviews[0].comment, '');
      expect(paginated.reviews[1].id, 1);
      expect(paginated.reviews[1].comment, 'محترم');
    });
  });
}
