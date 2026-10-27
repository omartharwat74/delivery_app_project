import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/orders/data/models/order_model.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/active_order_cubit.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/active_order_state.dart';

class MockTestOrderRepository implements OrderRepository {
  OrderOfferEntity? offerToReturn;
  OrderEntity? currentOrderToReturn;
  OrderEntity? acceptedOrderToReturn;
  OrderEntity? updatedOrderToReturn;
  Failure? failureToReturn;

  int getCurrentOfferCallCount = 0;
  int acceptOfferCallCount = 0;
  int updateOrderStatusCallCount = 0;
  String? lastUpdatedStatus;

  @override
  Future<Either<Failure, OrderOfferEntity?>> getCurrentOffer() async {
    getCurrentOfferCallCount++;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(offerToReturn);
  }

  @override
  Future<Either<Failure, OrderEntity>> acceptOffer(int offerId) async {
    acceptOfferCallCount++;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(acceptedOrderToReturn ??
        const OrderEntity(id: 9, code: 'AB12CD34', status: 'assigned'));
  }

  @override
  Future<Either<Failure, void>> rejectOffer(int offerId) async =>
      const Right(null);

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    updateOrderStatusCallCount++;
    lastUpdatedStatus = status;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(updatedOrderToReturn ??
        OrderEntity(id: orderId, code: 'CODE', status: status));
  }

  @override
  Future<Either<Failure, OrdersPaginatedResponse>> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  }) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    final items = currentOrderToReturn != null ? [currentOrderToReturn!] : <OrderEntity>[];
    return Right(OrdersPaginatedResponse(
      items: items.map((e) => OrderModel(id: e.id, code: e.code, status: e.status)).toList(),
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: items.length,
    ));
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(updatedOrderToReturn ??
        OrderEntity(id: orderId, code: 'CODE', status: 'assigned'));
  }
}

void main() {
  late MockTestOrderRepository mockRepo;
  late ActiveOrderCubit cubit;

  setUp(() {
    mockRepo = MockTestOrderRepository();
    cubit = ActiveOrderCubit(orderRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('ActiveOrderCubit Tests', () {
    test('initial state is ActiveOrderIdle', () {
      expect(cubit.state, const ActiveOrderIdle());
    });

    test('restoreActiveOrderOrOffer restores assigned order if active order exists', () async {
      mockRepo.currentOrderToReturn =
          const OrderEntity(id: 10, code: 'ORD10', status: 'assigned');

      await cubit.restoreActiveOrderOrOffer();

      expect(cubit.state, isA<ActiveOrderInProgress>());
      final inProgress = cubit.state as ActiveOrderInProgress;
      expect(inProgress.order.id, 10);
      expect(inProgress.isAssigned, isTrue);
    });

    test('restoreActiveOrderOrOffer restores on_the_way order if active order exists', () async {
      mockRepo.currentOrderToReturn =
          const OrderEntity(id: 11, code: 'ORD11', status: 'on_the_way');

      await cubit.restoreActiveOrderOrOffer();

      expect(cubit.state, isA<ActiveOrderInProgress>());
      final inProgress = cubit.state as ActiveOrderInProgress;
      expect(inProgress.order.id, 11);
      expect(inProgress.isOnTheWay, isTrue);
    });

    test('restoreActiveOrderOrOffer fetches waiting offer if no ongoing order', () async {
      mockRepo.currentOrderToReturn = null;
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 5,
        secondsLeft: 30,
        order: OrderEntity(id: 100, code: 'ORD100', status: 'ready_for_pickup'),
      );

      await cubit.restoreActiveOrderOrOffer();

      expect(cubit.state, isA<ActiveOrderOfferReceived>());
      final offerState = cubit.state as ActiveOrderOfferReceived;
      expect(offerState.offer.id, 5);
      expect(offerState.offer.order.id, 100);
      expect(cubit.remainingSeconds, 30);
    });

    test('acceptOffer successfully transitions from offer to assigned', () async {
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 7,
        secondsLeft: 40,
        order: OrderEntity(id: 101, code: 'ORD101', status: 'ready_for_pickup'),
      );
      await cubit.checkCurrentOffer();
      expect(cubit.state, isA<ActiveOrderOfferReceived>());

      mockRepo.acceptedOrderToReturn =
          const OrderEntity(id: 101, code: 'ORD101', status: 'assigned');

      await cubit.acceptOffer();

      expect(mockRepo.acceptOfferCallCount, 1);
      expect(cubit.state, isA<ActiveOrderInProgress>());
      final inProgress = cubit.state as ActiveOrderInProgress;
      expect(inProgress.order.status, 'assigned');
    });

    test('acceptOffer handles 422 / 404 by emitting error and going to idle', () async {
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 7,
        secondsLeft: 40,
        order: OrderEntity(id: 101, code: 'ORD101', status: 'ready_for_pickup'),
      );
      await cubit.checkCurrentOffer();

      mockRepo.failureToReturn = const ValidationFailure('العرض مش متاح.');

      await cubit.acceptOffer();

      expect(cubit.state, isA<ActiveOrderActionError>());
      final err = cubit.state as ActiveOrderActionError;
      expect(err.message, 'العرض مش متاح.');
      expect(err.nextState, const ActiveOrderIdle());
    });

    test('confirmPickup transitions assigned to on_the_way', () async {
      mockRepo.currentOrderToReturn =
          const OrderEntity(id: 12, code: 'ORD12', status: 'assigned');
      await cubit.restoreActiveOrderOrOffer();

      mockRepo.updatedOrderToReturn =
          const OrderEntity(id: 12, code: 'ORD12', status: 'on_the_way');

      await cubit.confirmPickup();

      expect(mockRepo.updateOrderStatusCallCount, 1);
      expect(mockRepo.lastUpdatedStatus, 'on_the_way');
      expect(cubit.state, isA<ActiveOrderInProgress>());
      final inProgress = cubit.state as ActiveOrderInProgress;
      expect(inProgress.order.status, 'on_the_way');
    });

    test('confirmDelivery transitions on_the_way to delivered and finishes order', () async {
      mockRepo.currentOrderToReturn =
          const OrderEntity(id: 13, code: 'ORD13', status: 'on_the_way');
      await cubit.restoreActiveOrderOrOffer();

      mockRepo.updatedOrderToReturn =
          const OrderEntity(id: 13, code: 'ORD13', status: 'delivered');

      await cubit.confirmDelivery();

      expect(mockRepo.updateOrderStatusCallCount, 1);
      expect(mockRepo.lastUpdatedStatus, 'delivered');
      expect(cubit.state, const ActiveOrderIdle());
    });
  });
}
