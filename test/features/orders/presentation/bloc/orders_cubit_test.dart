import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/orders/data/models/order_model.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/orders_state.dart';

class MockOrdersListRepository implements OrderRepository {
  String? lastScope;
  int? lastPage;
  int? lastPerPage;
  Failure? failure;

  @override
  Future<Either<Failure, OrdersPaginatedResponse>> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  }) async {
    lastScope = scope;
    lastPage = page;
    lastPerPage = perPage;

    if (failure != null) {
      return Left(failure!);
    }

    if (page == 1) {
      return Right(OrdersPaginatedResponse(
        items: [
          const OrderModel(id: 1, code: 'ORD1', status: 'assigned'),
          const OrderModel(id: 2, code: 'ORD2', status: 'assigned'),
        ],
        currentPage: 1,
        lastPage: 2,
        perPage: 2,
        total: 4,
      ));
    } else {
      return Right(OrdersPaginatedResponse(
        items: [
          const OrderModel(id: 3, code: 'ORD3', status: 'assigned'),
          const OrderModel(id: 4, code: 'ORD4', status: 'assigned'),
        ],
        currentPage: 2,
        lastPage: 2,
        perPage: 2,
        total: 4,
      ));
    }
  }

  @override
  Future<Either<Failure, OrderOfferEntity?>> getCurrentOffer() async =>
      const Right(null);
  @override
  Future<Either<Failure, OrderEntity>> acceptOffer(int offerId) async =>
      Left(ServerFailure(''));
  @override
  Future<Either<Failure, void>> rejectOffer(int offerId) async =>
      const Right(null);
  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    int orderId,
    String status,
  ) async =>
      Left(ServerFailure(''));
  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async =>
      Left(ServerFailure(''));
}

void main() {
  late MockOrdersListRepository repo;
  late OrdersCubit cubit;

  setUp(() {
    repo = MockOrdersListRepository();
    cubit = OrdersCubit(orderRepository: repo);
  });

  tearDown(() {
    cubit.close();
  });

  group('OrdersCubit Tests', () {
    test('initial state has default values', () {
      expect(cubit.state.status, OrdersStatus.initial);
      expect(cubit.state.orders, isEmpty);
      expect(cubit.state.currentPage, 1);
    });

    test('loadOrders loads first page successfully without scope', () async {
      await cubit.loadOrders();

      expect(cubit.state.status, OrdersStatus.loaded);
      expect(cubit.state.orders.length, 2);
      expect(cubit.state.currentPage, 1);
      expect(cubit.state.hasReachedMax, isFalse);
      expect(repo.lastScope, isNull);
      expect(repo.lastPage, 1);
    });

    test('refreshOrders fetches first page without scope', () async {
      await cubit.loadOrders();
      expect(cubit.state.orders.length, 2);

      await cubit.refreshOrders();
      expect(cubit.state.status, OrdersStatus.loaded);
      expect(cubit.state.orders.length, 2);
      expect(repo.lastScope, isNull);
      expect(repo.lastPage, 1);
    });

    test('loadMoreOrders appends items and updates hasReachedMax', () async {
      await cubit.loadOrders();
      expect(cubit.state.orders.length, 2);
      expect(cubit.state.hasReachedMax, isFalse);

      await cubit.loadMoreOrders();
      expect(cubit.state.orders.length, 4);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasReachedMax, isTrue);
      expect(repo.lastScope, isNull);
      expect(repo.lastPage, 2);
    });

    test('loadOrders handles failure correctly', () async {
      repo.failure = const ServerFailure('حدث خطأ');

      await cubit.loadOrders();

      expect(cubit.state.status, OrdersStatus.error);
      expect(cubit.state.errorMessage, 'حدث خطأ');
    });
  });
}
