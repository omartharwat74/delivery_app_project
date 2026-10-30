import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/features/orders/data/models/order_model.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';

void main() {
  group('Order Models Parsing Tests', () {
    test('OrderModel should parse correctly from Postman offer order JSON', () {
      final json = {
        "id": 9,
        "code": "AB12CD34",
        "status": "ready_for_pickup",
        "payment_method": "cash",
        "store": {
          "id": 4,
          "name": "ستور",
          "phone": "01012345678",
          "delivery_mode": "platform"
        },
        "customer": {"id": 8, "name": "Ahmed Test", "phone": "01012345678"},
        "items": [
          {
            "product_id": 12,
            "name": "برجر",
            "quantity": 2,
            "unit_price": 50,
            "line_total": 100
          }
        ],
        "summary": {
          "items_total": 100,
          "tax": 14,
          "delivery": 30,
          "total": 144
        },
        "earning": null,
        "address": {
          "id": 3,
          "name": "المنزل",
          "full_address": "القاهرة الجديدة",
          "lat": 30.0444,
          "long": 31.2357
        }
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, 9);
      expect(order.code, "AB12CD34");
      expect(order.status, "ready_for_pickup");
      expect(order.paymentMethod, "cash");
      expect(order.restaurantName, "ستور");
      expect(order.customerName, "Ahmed Test");
      expect(order.customerPhone, "01012345678");
      expect(order.totalItems, 2);
      expect(order.totalPrice, 144.0);
      expect(order.deliveryFee, 30.0);
      expect(order.pickupAddress, "ستور");
      expect(order.deliveryAddress, "القاهرة الجديدة");
    });

    test('OrderOfferModel should parse correctly from GET /orders/offer JSON', () {
      final json = {
        "id": 15,
        "expires_at": "2026-10-13T18:11:00+03:00",
        "seconds_left": 42,
        "order": {
          "id": 9,
          "code": "AB12CD34",
          "status": "ready_for_pickup",
          "payment_method": "cash",
          "store": {"name": "مطعم السلام"},
          "customer": {"name": "Mohamed", "phone": "01122334455"},
          "items": [],
          "summary": {"total": 150, "delivery": 25},
          "address": {"full_address": "مدينة نصر"}
        }
      };

      final offer = OrderOfferModel.fromJson(json);

      expect(offer.id, 15);
      expect(offer.secondsLeft, 42);
      expect(offer.expiresAt, isNotNull);
      expect(offer.order.id, 9);
      expect(offer.order.code, "AB12CD34");
      expect(offer.order.restaurantName, "مطعم السلام");
      expect(offer.order.deliveryAddress, "مدينة نصر");
    });

    test('OrdersPaginatedResponse should parse correctly', () {
      final json = {
        "items": [
          {
            "id": 9,
            "code": "AB12CD34",
            "status": "on_the_way",
            "earning": 30,
            "summary": {"total": 144}
          }
        ],
        "meta": {
          "current_page": 1,
          "last_page": 3,
          "per_page": 10,
          "total": 25
        }
      };

      final paginated = OrdersPaginatedResponse.fromJson(json);

      expect(paginated.items.length, 1);
      expect(paginated.currentPage, 1);
      expect(paginated.lastPage, 3);
      expect(paginated.perPage, 10);
      expect(paginated.total, 25);
    });

    test('OrderEntity progress segments calculation based on status', () {
      const assignedOrder = OrderEntity(
        id: 1,
        code: '1',
        status: 'assigned',
      );
      expect(assignedOrder.progressSegments, 1);
      expect(assignedOrder.isAssigned, isTrue);
      expect(assignedOrder.isOnTheWay, isFalse);
      expect(assignedOrder.isDelivered, isFalse);

      const onTheWayOrder = OrderEntity(
        id: 2,
        code: '2',
        status: 'on_the_way',
      );
      expect(onTheWayOrder.progressSegments, 2);
      expect(onTheWayOrder.isOnTheWay, isTrue);

      const deliveredOrder = OrderEntity(
        id: 3,
        code: '3',
        status: 'delivered',
      );
      expect(deliveredOrder.progressSegments, 3);
      expect(deliveredOrder.isDelivered, isTrue);
    });

    test('OrderEntity formattedPrice preserves decimals and does not strip fractions', () {
      const order1 = OrderEntity(
        id: 1,
        code: '1',
        status: 'assigned',
        summary: OrderSummaryEntity(total: 245.5),
      );
      expect(order1.formattedPrice, '245.5');

      const order2 = OrderEntity(
        id: 2,
        code: '2',
        status: 'assigned',
        summary: OrderSummaryEntity(total: 245.75),
      );
      expect(order2.formattedPrice, '245.75');

      const order3 = OrderEntity(
        id: 3,
        code: '3',
        status: 'assigned',
        summary: OrderSummaryEntity(total: 245.0),
      );
      expect(order3.formattedPrice, '245');

      const order4 = OrderEntity(
        id: 4,
        code: '4',
        status: 'assigned',
        earning: 25.5,
      );
      expect(order4.formattedPrice, '25.5');
    });
  });
}
