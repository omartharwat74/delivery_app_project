// ignore_for_file: unused_element
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/active_order_cubit.dart';
import '../bloc/active_order_state.dart';
import 'dashed_line_painter.dart';

/// ActiveOrderCard — Pixel-matched to Figma frames:
///   Frame 1984078515: Offer (قبول الطلب) – with timer fill-drain on button
///   Frame 1984078629: Heading to restaurant (تم استلام الطلب)
///   Frame 1984078630: Heading to customer (تم تسليم الطلب)
///
/// Design spec (from Figma node 7793-9407):
///   Flush bottom sheet: margin EdgeInsets.zero, radius 24 on top corners
///   Dark / Light mode aware colors
///   Primary red: #A3090F
class ActiveOrderCard extends StatelessWidget {
  /// The driver's current location to compute dynamic distance from driver to restaurant.
  final LatLng? driverLocation;

  /// Called when user taps "فتح الخريطة" next to the store row.
  final VoidCallback? onOpenStoreMap;

  /// Called when user taps "فتح الخريطة" next to the customer row.
  final VoidCallback? onOpenCustomerMap;

  const ActiveOrderCard({
    super.key,
    this.driverLocation,
    this.onOpenStoreMap,
    this.onOpenCustomerMap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveOrderCubit, ActiveOrderState>(
      listenWhen: (_, current) => current is ActiveOrderActionError,
      listener: (context, state) {
        if (state is ActiveOrderActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ActiveOrderIdle || state is ActiveOrderLoading) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final OrderEntity order;
        final bool isOffer = state is ActiveOrderOfferReceived;
        final bool inProgress = state is ActiveOrderInProgress;
        final bool isAccepting;
        final bool isUpdatingStatus;
        final int totalSecs;
        final int remainSecs;

        if (state is ActiveOrderOfferReceived) {
          order = state.offer.order;
          isAccepting = state.isAccepting;
          isUpdatingStatus = false;
          totalSecs = state.effectiveInitialSeconds;
          remainSecs = state.countdownSeconds;
        } else if (state is ActiveOrderInProgress) {
          order = state.order;
          isAccepting = false;
          isUpdatingStatus = state.isUpdatingStatus;
          totalSecs = 0;
          remainSecs = 0;
        } else {
          return const SizedBox.shrink();
        }

        final isAssigned = inProgress && order.isAssigned;
        final isOnTheWay = inProgress && order.isOnTheWay;

        // ── values ────────────────────────────────────────────────────────
        final displayPrice = order.formattedPrice;

        final itemsCountStr = order.totalItems > 0
            ? order.totalItems.toString()
            : (order.items.isNotEmpty ? order.items.length.toString() : '3');

        final orderIdStr =
            order.code.isNotEmpty ? order.code : order.id.toString();

        final storeName = order.restaurantName.isNotEmpty
            ? order.restaurantName
            : l10n.mockRestaurantName1;

        final fromAddress = order.pickupAddress.isNotEmpty
            ? order.pickupAddress
            : 'القاهره الجديده ، مدينتي ، حي الزهور';

        final toAddress = order.deliveryAddress.isNotEmpty
            ? order.deliveryAddress
            : 'القاهره الجديده ، مدينتي ، حي النور';

        final customerName = order.customerName.isNotEmpty
            ? order.customerName
            : l10n.drawerGuestName;

        final customerPhone = order.customerPhone.isNotEmpty
            ? order.customerPhone
            : '';

        // ── Dynamic Distance Calculation (Geolocator Crow-fly) ───────────
        // 1. Distance from Driver to Store:
        double? distDriverToStore;
        if (driverLocation != null &&
            order.store?.lat != null &&
            order.store?.long != null) {
          final meters = Geolocator.distanceBetween(
            driverLocation!.latitude,
            driverLocation!.longitude,
            order.store!.lat!,
            order.store!.long!,
          );
          distDriverToStore = meters / 1000.0;
        }

        // 2. Distance from Store to Customer Delivery Address:
        double? distStoreToCustomer;
        if (order.store?.lat != null &&
            order.store?.long != null &&
            order.address?.lat != null &&
            order.address?.long != null) {
          final meters = Geolocator.distanceBetween(
            order.store!.lat!,
            order.store!.long!,
            order.address!.lat!,
            order.address!.long!,
          );
          distStoreToCustomer = meters / 1000.0;
        }

        final String fromDist = distDriverToStore != null
            ? distDriverToStore.toStringAsFixed(1)
            : '2.5';

        final String toDist = distStoreToCustomer != null
            ? distStoreToCustomer.toStringAsFixed(1)
            : '5.0';

        final String totalDistance;
        if (distDriverToStore != null && distStoreToCustomer != null) {
          totalDistance =
              (distDriverToStore + distStoreToCustomer).toStringAsFixed(1);
        } else if (distStoreToCustomer != null) {
          totalDistance = (distStoreToCustomer + 2.5).toStringAsFixed(1);
        } else if (order.estimatedDistance?.isNotEmpty == true) {
          totalDistance = order.estimatedDistance!;
        } else {
          totalDistance = '7.5';
        }

        // countdown ratio 1.0 → 0.0 (full → empty), smoothly drains without resetting
        final double timerRatio = (isOffer && totalSecs > 0)
            ? (remainSecs / totalSecs).clamp(0.0, 1.0)
            : 1.0;

        final bottomSafePadding = MediaQuery.of(context).padding.bottom;

        // ── card container ────────────────────────────────────────────────
        return Container(
          // Flush to screen edges (no margin right, left, or bottom)
          margin: EdgeInsets.zero,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomSafePadding),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                width: 0.5,
              ),
              left: BorderSide(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                width: 0.5,
              ),
              right: BorderSide(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x33000000) : const Color(0x14000000),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. HEADER (Order ID on Right | Items • Price on Left) ─
                _HeaderRow(
                  orderIdStr: orderIdStr,
                  itemsCountStr: itemsCountStr,
                  displayPrice: displayPrice,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _Divider(isDark: isDark),
                const SizedBox(height: 12),

                // ── 2. STORE ROW (Logo on Right | Name on Left) ──────────
                _StoreRow(
                  storeName: storeName,
                  logoUrl: order.store?.logo,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _Divider(isDark: isDark),
                const SizedBox(height: 12),

                // ── 3. CUSTOMER SECTION (Stages 2 & 3 only) ──────────────
                if (!isOffer) ...[
                  _CustomerRow(
                    name: customerName,
                    phone: customerPhone,
                    l10n: l10n,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _Divider(isDark: isDark),
                  const SizedBox(height: 12),
                ],

                // ── 4. NOTE (if present) ──────────────────────────────────
                if (order.note != null && order.note!.trim().isNotEmpty) ...[
                  _NoteBox(note: order.note!),
                  const SizedBox(height: 12),
                ],

                // ── 5. نطاق التوصيل ───────────────────────────────────────
                _DeliveryScope(
                  fromAddress: fromAddress,
                  fromDist: fromDist,
                  toAddress: toAddress,
                  toDist: toDist,
                  onOpenStoreMap: onOpenStoreMap,
                  onOpenCustomerMap: onOpenCustomerMap,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _Divider(isDark: isDark),
                const SizedBox(height: 10),

                // ── 6. TOTAL DISTANCE ─────────────────────────────────────
                _TotalDistanceRow(
                  distance: totalDistance,
                  l10n: l10n,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // ── 7. ACTION BUTTON ──────────────────────────────────────
                if (isOffer)
                  _AcceptButton(
                    timerRatio: timerRatio,
                    isAccepting: isAccepting,
                    onAccept: () =>
                        context.read<ActiveOrderCubit>().acceptOffer(),
                    l10n: l10n,
                    isDark: isDark,
                  )
                else if (isAssigned)
                  _ActionButton(
                    label: l10n.trackingConfirmPickup,
                    loading: isUpdatingStatus,
                    onPressed: () =>
                        context.read<ActiveOrderCubit>().confirmPickup(),
                  )
                else if (isOnTheWay)
                  _ActionButton(
                    label: l10n.trackingConfirmDelivery,
                    loading: isUpdatingStatus,
                    onPressed: () =>
                        context.read<ActiveOrderCubit>().confirmDelivery(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── SUBWIDGETS ────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) => Divider(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
        height: 0.5,
        thickness: 0.5,
      );
}

/// Header row:
/// In RTL:
///   Start = RIGHT: Order ID: "طلب رقم : #10332"
///   End = LEFT: Items • Price: "3 منتجات • 340 ج.م"
/// In LTR:
///   Start = LEFT: Order ID: "Order No: #10332"
///   End = RIGHT: Items • Price: "3 Items • 340 EGP"
/// NO digital countdown badge!
class _HeaderRow extends StatelessWidget {
  final String orderIdStr;
  final String itemsCountStr;
  final String displayPrice;
  final AppLocalizations l10n;
  final bool isDark;

  const _HeaderRow({
    required this.orderIdStr,
    required this.itemsCountStr,
    required this.displayPrice,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Start: Order ID
        Text(
          l10n.trackingOrderNo(orderIdStr),
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),

        // End: Items & Price (Items count first, then price)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.trackingItems(itemsCountStr),
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(width: 6),
            const _Dot(),
            const SizedBox(width: 6),
            Text(
              '$displayPrice ${l10n.currencyEgp}',
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFFA3090F),
          shape: BoxShape.circle,
        ),
      );
}

/// Store row:
/// In RTL:
///   Child 0 (start = RIGHT): Circular Logo
///   Child 1 (to the left of logo): Restaurant Name
/// Restaurant phone and calling icon are COMPLETELY REMOVED per user instructions.
class _StoreRow extends StatelessWidget {
  final String storeName;
  final String? logoUrl;
  final bool isDark;

  const _StoreRow({
    required this.storeName,
    this.logoUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Logo circle on the RIGHT (start of row in RTL)
        ClipOval(
          child: logoUrl != null && logoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: logoUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => _DefaultLogo(),
                )
              : _DefaultLogo(),
        ),
        const SizedBox(width: 8),

        // 2. Restaurant name to the left of the logo
        Expanded(
          child: Text(
            storeName,
            style: TextStyle(
              fontFamily: 'ExpoArabic',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DefaultLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/orders/restaurant_ellipse.png',
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }
}

/// Customer section (Stages 2 & 3 only):
/// In RTL, CrossAxisAlignment.start aligns everything to the RIGHT edge.
/// Customer Name on top, Customer Phone with calling.svg below it.
class _CustomerRow extends StatelessWidget {
  final String name;
  final String phone;
  final AppLocalizations l10n;
  final bool isDark;

  const _CustomerRow({
    required this.name,
    required this.phone,
    required this.l10n,
    required this.isDark,
  });

  Future<void> _callPhone(BuildContext context, String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'تعذر فتح لوحة الاتصال'
                : 'Unable to open phone dialer'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isAr ? 'تعذر إجراء المكالمة' : 'Unable to make phone call'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trackingCustomerDetails,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _callPhone(context, phone),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/orders/smart_phone_02.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFA3090F),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1B1B1B),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFA3090F),
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String note;

  const _NoteBox({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.speaker_notes_outlined,
            color: Color(0xFFD97706),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 12,
                color: Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Delivery scope section:
/// In RTL:
///   Child 0 (start = RIGHT): Pin Icons Column (pin top | dashed vertical line | pin bottom)
///   Child 1 (middle): Address details (pickup + distance, dashed horizontal separator, delivery + distance)
///   Child 2 (end = LEFT): "فتح الخريطة" links
class _DeliveryScope extends StatelessWidget {
  final String fromAddress;
  final String fromDist;
  final String toAddress;
  final String toDist;
  final VoidCallback? onOpenStoreMap;
  final VoidCallback? onOpenCustomerMap;
  final AppLocalizations l10n;
  final bool isDark;

  const _DeliveryScope({
    required this.fromAddress,
    required this.fromDist,
    required this.toAddress,
    required this.toDist,
    required this.l10n,
    required this.isDark,
    this.onOpenStoreMap,
    this.onOpenCustomerMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: "نطاق التوصيل :" / "Delivery Range :"
        Text(
          l10n.trackingDeliveryScope,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 12),

        // Content Row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Pin icons column (RIGHT in RTL)
              // "من" pin is #1C1C1C in Light Mode and #FFFFFF in Dark Mode
              // "الى" pin remains #A3090F
              SizedBox(
                width: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SvgPicture.asset(
                        'assets/icons/orders/pin_location_01.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.white : const Color(0xFF1C1C1C),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: DashedLinePainter(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFE5E5E5),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SvgPicture.asset(
                        'assets/icons/orders/pin_location_01.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFA3090F),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 2. Address text column (MIDDLE)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From address + distance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackingFrom(fromAddress),
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.trackingExpectedDistanceShort(fromDist),
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFFA0A0A0)
                                : const Color(0xFF787878),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Horizontal dashed separator between pickup & delivery
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedHorizontalLinePainter(
                        color: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // To address + distance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackingTo(toAddress),
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.trackingExpectedDistanceShort(toDist),
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFFA0A0A0)
                                : const Color(0xFF787878),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. "فتح الخريطة" links (LEFT in RTL)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onOpenStoreMap,
                    child: Text(
                      l10n.trackingMapOpen,
                      style: const TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Color(0xFFA3090F),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onOpenCustomerMap,
                    child: Text(
                      l10n.trackingMapOpen,
                      style: const TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Color(0xFFA3090F),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Total distance row:
/// Icon comes BEFORE text ("قبل الكلام مش بعده").
/// In English, the arrow flips horizontally to adapt to LTR flow.
class _TotalDistanceRow extends StatelessWidget {
  final String distance;
  final AppLocalizations l10n;
  final bool isDark;

  const _TotalDistanceRow({
    required this.distance,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final iconColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Icon is BEFORE the text; direction changes in English (!isRtl)
        Transform.flip(
          flipX: !isRtl,
          child: SvgPicture.asset(
            'assets/icons/orders/arrow_move_up_right.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              iconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.trackingExpectedTotalDistance(distance),
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1B1B1B),
          ),
        ),
      ],
    );
  }
}

/// Accept button with the animated "hover" fill-drain:
/// The button starts with solid red (#A3090F). As time drains, the solid fill
/// shrinks towards the RIGHT, revealing the transparent hover background (#EE1C24 / #A3090F)
/// from the LEFT until it completely fills the button when time expires.
/// Matches Figma Component Set (Frame 1984078524, Property 1 = Default to Variant 9).
class _AcceptButton extends StatelessWidget {
  final double timerRatio; // 1.0 = full time, 0.0 = expired
  final bool isAccepting;
  final VoidCallback onAccept;
  final AppLocalizations l10n;
  final bool isDark;

  const _AcceptButton({
    required this.timerRatio,
    required this.isAccepting,
    required this.onAccept,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 48;
    const Color solidRed = Color(0xFFA3090F);
    final Color fadedRed =
        isDark ? const Color(0x33A3090F) : const Color(0x33EE1C24);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: buttonHeight,
        child: Stack(
          children: [
            // 1. Transparent hover background (fills 100%)
            Positioned.fill(
              child: Container(color: fadedRed),
            ),

            // 2. Solid red fill anchored to the RIGHT (eaten from the left as time expires)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 950),
                  curve: Curves.linear,
                  alignment: Alignment.centerRight,
                  widthFactor: timerRatio.clamp(0.0, 1.0),
                  child: Container(color: solidRed),
                ),
              ),
            ),

            // 3. Centered button label or progress indicator
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isAccepting ? null : onAccept,
                  splashColor: Colors.white24,
                  child: Center(
                    child: isAccepting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.trackingAcceptOrder,
                            style: const TextStyle(
                              fontFamily: 'ExpoArabic',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic solid action button (pickup / delivery confirm in Stages 2 & 3)
class _ActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA3090F),
          disabledBackgroundColor: const Color(0xFFA3090F).withAlpha(160),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
