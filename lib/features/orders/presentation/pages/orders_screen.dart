import 'package:flutter/material.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:delivery_app_project/features/orders/presentation/widgets/order_card.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/features/orders/presentation/pages/order_details_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = [
      OrderEntity(
        id: '1',
        restaurantName: l10n.mockRestaurantName1,
        pickupAddress: '123 شارع رئيسي',
        deliveryAddress: '456 شارع التوصيل',
        customerName: l10n.mockUserName1,
        customerPhone: '+1234567890',
        deliveryFee: 5.50,
        status: OrderStatus.waitingAcceptance,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        totalItems: 3,
        estimatedDistance: '2.4 km',
        estimatedTime: '20 : 15 دقيقة',
      ),
      OrderEntity(
        id: '2',
        restaurantName: l10n.mockRestaurantName2,
        pickupAddress: '789 طريق سريع',
        deliveryAddress: '101 شارع العميل',
        customerName: l10n.mockUserName2,
        customerPhone: '+1987654321',
        deliveryFee: 7.00,
        status: OrderStatus.courierOnWay,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        totalItems: 1,
        estimatedDistance: '1.2 km',
        estimatedTime: '08 : 05 دقيقة',
      ),
      OrderEntity(
        id: '3',
        restaurantName: l10n.mockRestaurantName3,
        pickupAddress: '222 شارع البيتزا',
        deliveryAddress: '333 طريق المستخدم',
        customerName: l10n.mockUserName3,
        customerPhone: '+1122334455',
        deliveryFee: 6.25,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        totalItems: 4,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: Row(
          children: [
            const AuthBackButton(),
            const SizedBox(width: 4),
            Text(
              l10n.ordersTitle,
              style: AppTextStyles.appBarTitle(context),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
            sliver: SliverList.separated(
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderCard(
                order: orders[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(order: orders[index]),
                  ),
                ),
              ),
              separatorBuilder: (_, _) => const SizedBox(height: 16),
            ),
          ),
        ],
      ),
    );
  }
}
