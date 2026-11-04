import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_back_button.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../widgets/dashed_line_painter.dart';

/// Completed Order Details Screen — Figma node-id: 10786-13123
/// Displayed when tapping a delivered order in Orders screen.
class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderEntity _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchLatestDetails();
  }

  Future<void> _fetchLatestDetails() async {
    final result = await di.sl<OrderRepository>().getOrderDetails(_order.id);

    if (!mounted) return;

    result.fold(
      (_) {},
      (freshOrder) {
        setState(() {
          _order = freshOrder;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const AuthBackButton(),
            const SizedBox(width: 4),
            Text(
              l10n.orderDetailsTitle,
              style: AppTextStyles.appBarTitle(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Order Header ─────────────────────────────────────
              _OrderHeader(order: _order),
              const _Divider(),

              // ── 2. Restaurant & Delivery Price ──────────────────────
              _RestaurantSection(order: _order),
              const _Divider(),

              // ── 3. Customer Info ────────────────────────────────────
              _CustomerSection(order: _order),
              const _Divider(),

              // ── 4. Delivery Route Scope ─────────────────────────────
              _DeliveryRouteSection(order: _order),
              if (_order.hasCustomerRating) ...[
                const _Divider(),
                _RatingSection(order: _order),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _OrderHeader extends StatelessWidget {
  final OrderEntity order;
  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Order ID (Start side)
        Text.rich(
          TextSpan(
            text: '${l10n.orderNoPrefix} ',
            style: TextStyle(
              fontFamily: 'ExpoArabic',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF787878),
            ),
            children: [
              TextSpan(
                text: '#${order.code.isNotEmpty ? order.code : order.id}',
                style: TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
        ),
        // Items • Price (End side)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.trackingItems(order.totalItems.toString()),
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFA3090F),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${order.formattedPrice} ${l10n.currencyEgp}',
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESTAURANT SECTION & DELIVERY PRICE
// ─────────────────────────────────────────────────────────────────────────────
class _RestaurantSection extends StatelessWidget {
  final OrderEntity order;
  const _RestaurantSection({required this.order});

  Widget _defaultLogo() {
    return Image.asset(
      'assets/images/restaurant/az_al_sham_logo.png',
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFA3090F).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.store_rounded,
          color: Color(0xFFA3090F),
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeLogo = order.store?.logo;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Restaurant Logo & Name (Start side)
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: storeLogo != null && storeLogo.isNotEmpty
                      ? Image.network(
                          storeLogo,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _defaultLogo(),
                        )
                      : _defaultLogo(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  order.restaurantName.isNotEmpty ? order.restaurantName : '---',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'ExpoArabic',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Delivery Price (End side)
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.deliveryPrice,
              style: const TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF787878),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.formattedDeliveryFee} ${l10n.currencyEgp}',
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerSection extends StatelessWidget {
  final OrderEntity order;
  const _CustomerSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trackingCustomerDetails,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          order.customerName.isNotEmpty ? order.customerName : '---',
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY ROUTE — vertical & horizontal dashed lines, pins & addresses
// ─────────────────────────────────────────────────────────────────────────────
class _DeliveryRouteSection extends StatelessWidget {
  final OrderEntity order;
  const _DeliveryRouteSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor =
        isDark ? const Color(0xFF383838) : const Color(0xFFE5E5E5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trackingDeliveryScope,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vertical pins with dashed connector
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/orders/pin_location_01.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : const Color(0xFF1B1B1B),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(
                  height: 16,
                  width: 2,
                  child: CustomPaint(
                    painter: DashedLinePainter(
                      color: lineColor,
                      strokeWidth: 1.0,
                      dashWidth: 2.0,
                      dashSpace: 2.0,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/orders/pin_location_01.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFA3090F),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Addresses with horizontal dashed divider
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${l10n.fromPrefix} ',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFFA0A0A0)
                            : const Color(0xFF787878),
                      ),
                      children: [
                        TextSpan(
                          text: order.pickupAddress.isNotEmpty
                              ? order.pickupAddress
                              : '---',
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark ? Colors.white : const Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: DashedHorizontalLinePainter(
                      color: isDark
                          ? const Color(0xFF262626)
                          : const Color(0xFFE5E5E5),
                      strokeWidth: 1.0,
                      dashWidth: 2.0,
                      dashSpace: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      text: '${l10n.toPrefix} ',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFFA0A0A0)
                            : const Color(0xFF787878),
                      ),
                      children: [
                        TextSpan(
                          text: order.deliveryAddress.isNotEmpty
                              ? order.deliveryAddress
                              : '---',
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isDark ? Colors.white : const Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RATING SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _RatingSection extends StatelessWidget {
  final OrderEntity order;
  const _RatingSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final rating = order.customerRating;
    if (rating == null || rating <= 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviewText = (order.customerReview != null &&
            order.customerReview!.trim().isNotEmpty)
        ? order.customerReview!
        : l10n.orderReviewDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customerReview,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) {
              final starValue = index + 1;
              final Widget starWidget;
              if (rating >= starValue) {
                starWidget = Image.asset(
                  'assets/images/orders/star_full.png',
                  width: 20,
                  height: 20,
                );
              } else if (rating >= starValue - 0.5) {
                starWidget = Image.asset(
                  'assets/images/orders/star_half.png',
                  width: 20,
                  height: 20,
                );
              } else {
                starWidget = Image.asset(
                  'assets/images/orders/star_full.png',
                  width: 20,
                  height: 20,
                  color: isDark
                      ? const Color(0xFF404040)
                      : const Color(0xFFE0E0E0),
                );
              }
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: starWidget,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reviewText,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1B1B1B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIVIDER
// ─────────────────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
      ),
    );
  }
}
