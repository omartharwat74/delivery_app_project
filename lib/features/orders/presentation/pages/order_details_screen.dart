import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../bloc/active_order_cubit.dart';

/// Order Details Screen — Figma node-id: 7811-9813
/// Layout: Real map image (40%) → overlapping white details card (60%+).
/// Entire layout is RTL. All content is right-aligned (start = right).
class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderEntity _order;
  bool _isLoading = false;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchLatestDetails();
  }

  Future<void> _fetchLatestDetails() async {
    setState(() => _isLoading = true);

    final result = await di.sl<OrderRepository>().getOrderDetails(_order.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        // If 404 or failure, show server error message and pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      },
      (freshOrder) {
        setState(() {
          _order = freshOrder;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _handleConfirmPickup() async {
    setState(() => _isActionLoading = true);

    final result =
        await di.sl<OrderRepository>().updateOrderStatus(_order.id, 'on_the_way');

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchLatestDetails();
      },
      (updatedOrder) {
        setState(() => _order = updatedOrder);
        di.sl<ActiveOrderCubit>().restoreActiveOrderOrOffer();
      },
    );
  }

  Future<void> _handleConfirmDelivery() async {
    setState(() => _isActionLoading = true);

    final result =
        await di.sl<OrderRepository>().updateOrderStatus(_order.id, 'delivered');

    if (!mounted) return;
    setState(() => _isActionLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchLatestDetails();
      },
      (updatedOrder) {
        setState(() => _order = updatedOrder);
        di.sl<ActiveOrderCubit>().restoreActiveOrderOrOffer();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Transform.flip(
                flipX: Directionality.of(context) == TextDirection.ltr,
                child: Image.asset(
                  'assets/images/orders/back.png',
                  width: 28,
                  height: 28,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.localeName == 'ar' ? 'تفاصيل الطلب' : 'Order Details',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'ExpoArabic',
              ),
            ),
          ],
        ),
      ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            return Stack(
              children: [
                // ── Real map image — 40% to 45% of available height ─────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: availableHeight * 0.45,
                  child: Image.asset(
                    'assets/images/map_placeholder.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFD6E4F0),
                      child: Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 70,
                          color: Colors.blueGrey.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Details card overlapping the map ──────────────────────────
                Positioned(
                  top: availableHeight * 0.40,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141414) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x33000000)
                              : const Color(0x18000000),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                          // ── Order Header ─────────────────────────────────────
                          _OrderHeader(order: _order),
                          const _Divider(),

                          // ── Restaurant Info ───────────────────────────────────
                          _RestaurantSection(order: _order),
                          const _Divider(),

                          // ── Customer Info ─────────────────────────────────────
                          _CustomerSection(order: _order),
                          const _Divider(),

                          // ── Delivery Route ────────────────────────────────────
                          _DeliveryRouteSection(order: _order),
                          const _Divider(),

                          // ── Customer Rating ───────────────────────────────────
                          // TODO(API): static for now
                          const _RatingSection(),

                          // ── Active Order Action Button ──────────────────────
                          if (_order.isAssigned) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isActionLoading
                                  ? null
                                  : _handleConfirmPickup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isActionLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      l10n.trackingConfirmPickup,
                                      style: AppTextStyles.buttonHeading(
                                        context,
                                      ).copyWith(color: Colors.white),
                                    ),
                            ),
                          ] else if (_order.isOnTheWay) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isActionLoading
                                  ? null
                                  : _handleConfirmDelivery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isActionLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      l10n.trackingConfirmDelivery,
                                      style: AppTextStyles.buttonHeading(
                                        context,
                                      ).copyWith(color: Colors.white),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
    final displayPrice = order.formattedPrice;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Order ID
        Text(
          l10n.trackingOrderNo(
              order.code.isNotEmpty ? order.code : order.id.toString()),
          style: AppTextStyles.body(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        // Items • Price
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.trackingItems(order.totalItems.toString()),
              style: AppTextStyles.caption(context).copyWith(
                fontSize: 12,
                color:
                    isDark ? const Color(0xFFA0A0A0) : const Color(0xFF787878),
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
              '$displayPrice ${l10n.currencyEgp}',
              style: AppTextStyles.caption(context).copyWith(
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
// RESTAURANT SECTION — all content starts from the right
// ─────────────────────────────────────────────────────────────────────────────
class _RestaurantSection extends StatelessWidget {
  final OrderEntity order;
  const _RestaurantSection({required this.order});

  Widget _defaultLogo(Color primary) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.store_rounded, color: primary, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storeLogo = order.store?.logo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: storeLogo != null && storeLogo.isNotEmpty
                  ? Image.network(
                      storeLogo,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _defaultLogo(primary),
                    )
                  : Image.asset(
                      'assets/images/orders/az_al_sham_logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _defaultLogo(primary),
                    ),
            ),
            const SizedBox(width: 10),
            // Name + phone + icon grouped together
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if ((order.store?.phone ?? order.customerPhone).isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _RedCallIcon(),
                        const SizedBox(width: 8),
                        Text(
                          order.store?.phone ?? order.customerPhone,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.caption(context).copyWith(
                            fontSize: 12,
                            color: AppColors.paragraph(context),
                          ),
                        ),
                      ],
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
// CUSTOMER SECTION — all content starts from the right
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
          style: AppTextStyles.body(context).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customerName,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
            if (order.customerPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _RedSmartphoneIcon(),
                  const SizedBox(width: 8),
                  Text(
                    order.customerPhone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFA0A0A0)
                          : AppColors.paragraph(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY ROUTE — vertical dotted timeline, all start-aligned
// ─────────────────────────────────────────────────────────────────────────────
class _DeliveryRouteSection extends StatelessWidget {
  final OrderEntity order;
  const _DeliveryRouteSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trackingDeliveryScope,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical icon column with dotted connector
            Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/orders/pin_location.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black87,
                      BlendMode.srcIn),
                ),
                SizedBox(
                  height: 36,
                  width: 2,
                  child: CustomPaint(painter: _DottedLinePainter()),
                ),
                SvgPicture.asset(
                  'assets/icons/orders/pin_location.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.primary, BlendMode.srcIn),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Addresses column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trackingFrom(order.pickupAddress),
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.trackingTo(order.deliveryAddress),
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
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
  const _RatingSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'تقييم العميل :' : 'Customer Review :',
          style: AppTextStyles.body(context).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) {
              if (index == 4) {
                return Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Image.asset(
                    'assets/images/orders/star_half.png',
                    width: 22,
                    height: 22,
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Image.asset(
                  'assets/images/orders/star_full.png',
                  width: 22,
                  height: 22,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAr
              ? 'المندوب كان في غاية من الاحترام ، والسرعة'
              : 'The delivery driver was very polite and fast',
          style: AppTextStyles.body(context).copyWith(
            fontSize: 12,
            color: isDark
                ? const Color(0xFFA0A0A0)
                : AppColors.paragraph(context),
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _RedCallIcon extends StatelessWidget {
  const _RedCallIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/orders/calling.svg',
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
  }
}

class _RedSmartphoneIcon extends StatelessWidget {
  const _RedSmartphoneIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/orders/smart_phone.svg',
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dash = 4.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
