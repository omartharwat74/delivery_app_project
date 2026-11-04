import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_app_project/core/di/injection_container.dart' as di;
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/orders/data/models/order_model.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app_project/features/orders/presentation/pages/order_details_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class MockOrderRepository implements OrderRepository {
  OrderEntity? orderToReturn;

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
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async {
    if (orderToReturn != null) {
      return Right(orderToReturn!);
    }
    return Left(ServerFailure('not found'));
  }
}

void main() {
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    if (di.sl.isRegistered<OrderRepository>()) {
      di.sl.unregister<OrderRepository>();
    }
    di.sl.registerSingleton<OrderRepository>(mockOrderRepository);
  });

  tearDown(() {
    if (di.sl.isRegistered<OrderRepository>()) {
      di.sl.unregister<OrderRepository>();
    }
  });

  const testOrder = OrderEntity(
    id: 10332,
    code: '10332',
    status: 'delivered',
    earning: 70.0,
    store: OrderStoreEntity(
      id: 1,
      name: 'مطعم عز الشام',
      address: 'القاهره الجديده ، مدينتي ، حي الزهور',
    ),
    customer: OrderCustomerEntity(
      id: 1,
      name: 'احمد فرج',
      phone: '01000000000',
    ),
    address: OrderAddressEntity(
      id: 1,
      fullAddress: 'القاهره الجديده ، مدينتي ، حي النور',
    ),
    items: [
      OrderItemEntity(
        name: 'وجبة 1',
        quantity: 1,
        unitPrice: 100,
        lineTotal: 100,
      ),
      OrderItemEntity(
        name: 'وجبة 2',
        quantity: 2,
        unitPrice: 120,
        lineTotal: 240,
      ),
    ],
    summary: OrderSummaryEntity(
      itemsTotal: 340,
      delivery: 70,
      total: 340,
    ),
    customerRating: 4.5,
  );

  Widget createWidget(
    OrderEntity order, {
    Locale locale = const Locale('ar'),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      locale: locale,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrderDetailsScreen(order: order),
    );
  }

  testWidgets('renders completed order details in Arabic (Figma pixel-match)',
      (tester) async {
    await tester.pumpWidget(createWidget(testOrder, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    // App bar
    expect(find.text('تفاصيل الطلب'), findsOneWidget);

    // Section 1: Order Header
    expect(find.text('طلب رقم : #10332'), findsOneWidget);
    expect(find.text('340 ج.م'), findsOneWidget);
    expect(find.text('3 منتجات'), findsOneWidget);

    // Section 2: Restaurant & Delivery Fee
    expect(find.text('مطعم عز الشام'), findsOneWidget);
    expect(find.text('سعر التوصيل'), findsOneWidget);
    expect(find.text('70 ج.م'), findsOneWidget);

    // Section 3: Customer Details
    expect(find.text('بيانات العميل :'), findsOneWidget);
    expect(find.text('احمد فرج'), findsOneWidget);

    // Section 4: Delivery Range
    expect(find.text('نطاق التوصيل :'), findsOneWidget);
    expect(
      find.text('من : القاهره الجديده ، مدينتي ، حي الزهور'),
      findsOneWidget,
    );
    expect(
      find.text('الى : القاهره الجديده ، مدينتي ، حي النور'),
      findsOneWidget,
    );

    // Section 5: Review
    expect(find.text('تقييم العميل :'), findsOneWidget);
    expect(
      find.text('المندوب كان في غاية من الاحترام ، والسرعة'),
      findsOneWidget,
    );

    // Ensure action buttons from active orders are NOT present
    expect(find.text('تأكيد الاستلام'), findsNothing);
    expect(find.text('تأكيد التسليم'), findsNothing);
  });

  testWidgets('renders completed order details in English', (tester) async {
    await tester.pumpWidget(createWidget(testOrder, locale: const Locale('en')));
    await tester.pumpAndSettle();

    // App bar
    expect(find.text('Order Details'), findsOneWidget);

    // Section 1: Order Header
    expect(find.text('Order No : #10332'), findsOneWidget);
    expect(find.text('340 EGP'), findsOneWidget);
    expect(find.text('3 Items'), findsOneWidget);

    // Section 2: Restaurant & Delivery Fee
    expect(find.text('مطعم عز الشام'), findsOneWidget);
    expect(find.text('Delivery Price'), findsOneWidget);
    expect(find.text('70 EGP'), findsOneWidget);

    // Section 3: Customer Details
    expect(find.text('Customer Details :'), findsOneWidget);
    expect(find.text('احمد فرج'), findsOneWidget);

    // Section 4: Delivery Range
    expect(find.text('Delivery Range :'), findsOneWidget);
    expect(find.textContaining('From : '), findsOneWidget);
    expect(find.textContaining('To : '), findsOneWidget);

    // Section 5: Review
    expect(find.text('Customer Review :'), findsOneWidget);
    expect(
      find.text('The delivery driver was very polite and fast'),
      findsOneWidget,
    );
  });

  testWidgets('hides customer review section completely when customerRating is null',
      (tester) async {
    const unratedOrder = OrderEntity(
      id: 10333,
      code: '10333',
      status: 'delivered',
      customerRating: null,
      customerReview: null,
    );

    await tester.pumpWidget(createWidget(unratedOrder, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('تقييم العميل :'), findsNothing);
    expect(find.text('المندوب كان في غاية من الاحترام ، والسرعة'), findsNothing);
  });

  testWidgets('hides customer review section completely when customerRating is 0',
      (tester) async {
    const zeroRatedOrder = OrderEntity(
      id: 10334,
      code: '10334',
      status: 'delivered',
      customerRating: 0.0,
      customerReview: 'some review',
    );

    await tester.pumpWidget(createWidget(zeroRatedOrder, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('تقييم العميل :'), findsNothing);
    expect(find.text('some review'), findsNothing);
  });

  testWidgets('shows customer review section when customerRating is greater than 0',
      (tester) async {
    const ratedOrder = OrderEntity(
      id: 10335,
      code: '10335',
      status: 'delivered',
      customerRating: 5.0,
      customerReview: 'خدمة رائعة جدا ومميزة',
    );

    await tester.pumpWidget(createWidget(ratedOrder, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('تقييم العميل :'), findsOneWidget);
    expect(find.text('خدمة رائعة جدا ومميزة'), findsOneWidget);
  });

  testWidgets('renders cleanly in dark mode without error', (tester) async {
    await tester.pumpWidget(
      createWidget(
        testOrder,
        locale: const Locale('ar'),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(find.text('طلب رقم : #10332'), findsOneWidget);
  });
}
