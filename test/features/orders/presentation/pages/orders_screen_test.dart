import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_app_project/core/di/injection_container.dart' as di;
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/orders/data/models/order_model.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/orders_state.dart';
import 'package:delivery_app_project/features/orders/presentation/pages/order_details_screen.dart';
import 'package:delivery_app_project/features/orders/presentation/pages/orders_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class MockOrderRepo implements OrderRepository {
  @override
  Future<Either<Failure, OrderOfferEntity?>> getCurrentOffer() async =>
      const Right(null);

  @override
  Future<Either<Failure, OrderEntity>> acceptOffer(int offerId) async =>
      Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, void>> rejectOffer(int offerId) async =>
      const Right(null);

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    int orderId,
    String status,
  ) async =>
      Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, OrdersPaginatedResponse>> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  }) async =>
      const Right(
        OrdersPaginatedResponse(
          items: [],
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 0,
        ),
      );

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async =>
      Left(ServerFailure('not implemented'));
}

class FakeOrdersCubit extends OrdersCubit {
  FakeOrdersCubit(List<OrderEntity> orders)
      : super(orderRepository: MockOrderRepo()) {
    emit(OrdersState(status: OrdersStatus.loaded, orders: orders));
  }
}

void main() {
  setUp(() {
    if (di.sl.isRegistered<OrderRepository>()) {
      di.sl.unregister<OrderRepository>();
    }
    di.sl.registerSingleton<OrderRepository>(MockOrderRepo());
  });

  tearDown(() {
    if (di.sl.isRegistered<OrderRepository>()) {
      di.sl.unregister<OrderRepository>();
    }
  });

  const deliveredOrder = OrderEntity(
    id: 101,
    code: 'ORD-101',
    status: 'delivered',
    earning: 70.0,
    store: OrderStoreEntity(name: 'مطعم عز الشام'),
    customer: OrderCustomerEntity(name: 'عميل مسلّم', phone: '0100'),
    summary: OrderSummaryEntity(total: 250),
  );

  const activeOrder = OrderEntity(
    id: 102,
    code: 'ORD-102',
    status: 'assigned',
    earning: 50.0,
    store: OrderStoreEntity(name: 'برجر كنج'),
    customer: OrderCustomerEntity(name: 'عميل نشط', phone: '0111'),
    summary: OrderSummaryEntity(total: 180),
  );

  testWidgets('tapping delivered order navigates to OrderDetailsScreen',
      (tester) async {
    final cubit = FakeOrdersCubit([deliveredOrder]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<OrdersCubit>.value(
          value: cubit,
          child: const OrdersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مطعم عز الشام'), findsOneWidget);
    await tester.tap(find.text('مطعم عز الشام'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailsScreen), findsOneWidget);
    expect(find.text('تفاصيل الطلب'), findsOneWidget);
  });

  testWidgets(
      'tapping active order (e.g. assigned) pops back to previous route (Home)',
      (tester) async {
    final cubit = FakeOrdersCubit([activeOrder]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<OrdersCubit>.value(
                          value: cubit,
                          child: const OrdersScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Orders'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to OrdersScreen
    await tester.tap(find.text('Go to Orders'));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersScreen), findsOneWidget);

    // Tap active order card
    expect(find.text('برجر كنج'), findsOneWidget);
    await tester.tap(find.text('برجر كنج'));
    await tester.pumpAndSettle();

    // Should pop back to Home / previous screen
    expect(find.byType(OrdersScreen), findsNothing);
    expect(find.text('Go to Orders'), findsOneWidget);
  });
}
