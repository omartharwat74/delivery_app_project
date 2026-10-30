import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/presentation/widgets/order_card.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget(OrderEntity order, {Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: OrderCard(order: order),
      ),
    );
  }

  testWidgets('does not render any review badge', (tester) async {
    const order = OrderEntity(
      id: 1,
      code: 'ORD-001',
      status: 'delivered',
      store: OrderStoreEntity(name: 'مطعم السعادة'),
      isReviewed: false,
    );

    await tester.pumpWidget(createWidget(order));
    await tester.pumpAndSettle();

    expect(find.text('لم يتم التقييم'), findsNothing);
    expect(find.text('تم التقييم'), findsNothing);
    expect(find.text('Not Reviewed'), findsNothing);
    expect(find.text('Reviewed'), findsNothing);
  });

  testWidgets('formats estimated time with localized minute in Arabic', (tester) async {
    const order = OrderEntity(
      id: 2,
      code: 'ORD-002',
      status: 'delivered',
      store: OrderStoreEntity(name: 'مطعم السعادة'),
      estimatedTime: '20 : 15 دقيقة',
    );

    await tester.pumpWidget(createWidget(order, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('20 : 15 دقيقة'), findsOneWidget);
  });

  testWidgets('formats estimated time with localized minute in English', (tester) async {
    const order = OrderEntity(
      id: 3,
      code: 'ORD-003',
      status: 'delivered',
      store: OrderStoreEntity(name: 'Happy Restaurant'),
      estimatedTime: '20 : 15 دقيقة',
    );

    await tester.pumpWidget(createWidget(order, locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('20 : 15 mins'), findsOneWidget);
  });

  testWidgets('displays decimal price correctly without stripping fractions (e.g. 245.5 ج.م)', (tester) async {
    const order = OrderEntity(
      id: 4,
      code: 'ORD-004',
      status: 'assigned',
      store: OrderStoreEntity(name: 'مطعم السعادة'),
      summary: OrderSummaryEntity(total: 245.5),
    );

    await tester.pumpWidget(createWidget(order, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('245.5 ج.م'), findsOneWidget);
  });

  testWidgets('displays two decimal fractions correctly (e.g. 245.75 EGP)', (tester) async {
    const order = OrderEntity(
      id: 5,
      code: 'ORD-005',
      status: 'assigned',
      store: OrderStoreEntity(name: 'Happy Restaurant'),
      summary: OrderSummaryEntity(total: 245.75),
    );

    await tester.pumpWidget(createWidget(order, locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('245.75 EGP'), findsOneWidget);
  });
}
