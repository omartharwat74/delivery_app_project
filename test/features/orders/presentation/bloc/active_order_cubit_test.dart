import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/localization/locale_controller.dart';
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
      items: items.map((e) => OrderModel(
        id: e.id,
        code: e.code,
        status: e.status,
        store: e.store != null
            ? OrderStoreModel(id: e.store!.id, name: e.store!.name)
            : null,
      )).toList(),
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: items.length,
    ));
  }

  int getOrderDetailsCallCount = 0;

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async {
    getOrderDetailsCallCount++;
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

    test('offer flow starts 5-second polling timer and countdown timer', () async {
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 20,
        secondsLeft: 30,
        order: OrderEntity(id: 200, code: 'ORD200', status: 'ready_for_pickup'),
      );

      await cubit.checkCurrentOffer();

      expect(cubit.state, isA<ActiveOrderOfferReceived>());
      expect(cubit.isPollingActive, isTrue);
      expect(cubit.remainingSeconds, 30);
    });

    test('when offer becomes null on check, state transitions to ActiveOrderIdle and timers cancel', () async {
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 21,
        secondsLeft: 30,
        order: OrderEntity(id: 201, code: 'ORD201', status: 'ready_for_pickup'),
      );
      await cubit.checkCurrentOffer();
      expect(cubit.isPollingActive, isTrue);

      // Offer expires or taken by another driver -> null
      mockRepo.offerToReturn = null;
      await cubit.checkCurrentOffer();

      expect(cubit.state, const ActiveOrderIdle());
      expect(cubit.isPollingActive, isFalse);
    });

    test('startFallbackPolling polls offer when idle and online', () async {
      mockRepo.offerToReturn = null;
      var isOnlineValue = true;

      cubit.startFallbackPolling(
        interval: const Duration(milliseconds: 50),
        isOnline: () => isOnlineValue,
      );

      expect(cubit.isFallbackPollingActive, isTrue);

      await Future.delayed(const Duration(milliseconds: 120));
      expect(mockRepo.getCurrentOfferCallCount, greaterThanOrEqualTo(2));

      cubit.stopFallbackPolling();
      expect(cubit.isFallbackPollingActive, isFalse);
    });

    test('startFallbackPolling does not poll when offline', () async {
      final initialCallCount = mockRepo.getCurrentOfferCallCount;

      cubit.startFallbackPolling(
        interval: const Duration(milliseconds: 50),
        isOnline: () => false,
      );

      await Future.delayed(const Duration(milliseconds: 120));
      expect(mockRepo.getCurrentOfferCallCount, initialCallCount);

      cubit.stopFallbackPolling();
    });

    test('reloadActiveOrder reloads order details and updates state when ActiveOrderInProgress', () async {
      mockRepo.currentOrderToReturn = const OrderEntity(
        id: 42,
        code: 'ORD42',
        status: 'assigned',
        store: OrderStoreEntity(name: 'مطعم الأصيل'),
      );
      await cubit.restoreActiveOrderOrOffer();
      expect(cubit.state, isA<ActiveOrderInProgress>());
      expect((cubit.state as ActiveOrderInProgress).order.restaurantName, 'مطعم الأصيل');

      // Now backend responds with localized restaurant name
      mockRepo.updatedOrderToReturn = const OrderEntity(
        id: 42,
        code: 'ORD42',
        status: 'assigned',
        store: OrderStoreEntity(name: 'Al Aseel Restaurant'),
      );

      await cubit.reloadActiveOrder();

      expect(mockRepo.getOrderDetailsCallCount, 1);
      expect(cubit.state, isA<ActiveOrderInProgress>());
      expect((cubit.state as ActiveOrderInProgress).order.restaurantName, 'Al Aseel Restaurant');
    });

    test('reloadActiveOrder does nothing when state is ActiveOrderIdle or ActiveOrderOfferReceived', () async {
      // 1. Idle state
      expect(cubit.state, const ActiveOrderIdle());
      await cubit.reloadActiveOrder();
      expect(mockRepo.getOrderDetailsCallCount, 0);

      // 2. Offer received state (waiting to be accepted)
      mockRepo.offerToReturn = const OrderOfferEntity(
        id: 1,
        secondsLeft: 20,
        order: OrderEntity(id: 101, code: 'OFFER01', status: 'ready_for_pickup'),
      );
      await cubit.checkCurrentOffer();
      expect(cubit.state, isA<ActiveOrderOfferReceived>());

      await cubit.reloadActiveOrder();
      // Should not call getOrderDetails or disrupt offer state
      expect(mockRepo.getOrderDetailsCallCount, 0);
      expect(cubit.state, isA<ActiveOrderOfferReceived>());
    });

    test('automatically reloads active order when LocaleController triggers language change', () async {
      SharedPreferences.setMockInitialValues({'driver_app_locale': 'ar'});
      final prefs = await SharedPreferences.getInstance();
      final localeController = LocaleController(prefs);
      localeController.hydrate();

      final localizedCubit = ActiveOrderCubit(
        orderRepository: mockRepo,
        localeController: localeController,
      );

      mockRepo.currentOrderToReturn = const OrderEntity(
        id: 77,
        code: 'ORD77',
        status: 'on_the_way',
        store: OrderStoreEntity(name: 'برجر كلاسيك'),
      );
      await localizedCubit.restoreActiveOrderOrOffer();
      expect(localizedCubit.state, isA<ActiveOrderInProgress>());

      mockRepo.updatedOrderToReturn = const OrderEntity(
        id: 77,
        code: 'ORD77',
        status: 'on_the_way',
        store: OrderStoreEntity(name: 'Classic Burger'),
      );

      // Trigger language change
      await localeController.setLocale(const Locale('en'));
      await Future<void>.delayed(Duration.zero);

      expect(mockRepo.getOrderDetailsCallCount, 1);
      expect(localizedCubit.state, isA<ActiveOrderInProgress>());
      expect(
        (localizedCubit.state as ActiveOrderInProgress).order.restaurantName,
        'Classic Burger',
      );

      localizedCubit.close();
    });
  });
}
