import 'package:flutter/material.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

/// OrderCard — pixel-matched to the Figma screenshot (RTL layout).
class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  String _statusLabel(AppLocalizations l10n) {
    switch (order.status) {
      case 'assigned':
        return l10n.orderStatusAssigned;
      case 'on_the_way':
        return l10n.orderStatusOnWay;
      case 'delivered':
        return l10n.orderStatusDelivered;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return l10n.orderStatusNew;
    }
  }

  String _subStatusLabel(AppLocalizations l10n) {
    switch (order.status) {
      case 'assigned':
        return l10n.orderStatusAssignedSub;
      case 'on_the_way':
        return l10n.orderStatusOnWaySub;
      case 'delivered':
        return l10n.orderStatusDeliveredSub;
      case 'cancelled':
        return l10n.orderStatusCancelled;
      default:
        return l10n.orderStatusNew;
    }
  }

  Color _statusColor() {
    switch (order.status) {
      case 'assigned':
        return AppColors.statusWarning;
      case 'on_the_way':
        return AppColors.primary;
      case 'delivered':
      case 'cancelled':
        return const Color(0xFF9E9E9E); // grey for closed
      default:
        return AppColors.primary;
    }
  }

  String _formatEstimatedTime(String? time, AppLocalizations l10n) {
    if (time == null || time.isEmpty) return '';
    final cleaned = time
        .replaceAll('دقيقة', '')
        .replaceAll('دقائق', '')
        .replaceAll('mins', '')
        .replaceAll('min', '')
        .trim();
    return '$cleaned ${l10n.minutes}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF262626)
                  : const Color(0xFFE5E5E5),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x33000000)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── TOP ROW ───────────────────────────────────────────────
                // Right group: logo + name  |  Left group: items • price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── RIGHT: logo + name ──────────────────────────────
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/orders/restaurant_ellipse.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              order.restaurantName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyles.body(context).copyWith(
                                fontFamily: 'ExpoArabic',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1B1B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── LEFT: Items • Price ────────────────────────────
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.trackingItems(order.totalItems.toString()),
                          style: AppTextStyles.caption(context).copyWith(
                            fontFamily: 'ExpoArabic',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFFA0A0A0)
                                : AppColors.paragraph(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${order.formattedPrice} ${l10n.currencyEgp}',
                          style: AppTextStyles.body(context).copyWith(
                            fontFamily: 'ExpoArabic',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Divider(
                  height: 20,
                  thickness: 0.5,
                  color: isDark
                      ? const Color(0xFF262626)
                      : AppColors.border(context),
                ),

                // ── MIDDLE ROW ────────────────────────────────────────────
                // Right: status icon (40×40) + status label / substatus
                // Left:  "وقت التوصيل المتوقع"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Order status icon — 40×40
                    Image.asset(
                      'assets/images/orders/order_status_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    // Status label column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusLabel(l10n),
                            style: AppTextStyles.caption(context).copyWith(
                              fontFamily: 'ExpoArabic',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _statusColor(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subStatusLabel(l10n),
                            style: AppTextStyles.body(context).copyWith(
                              fontFamily: 'ExpoArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1B1B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expected time column
                    if (order.estimatedTime != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.orderEstTime,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(context).copyWith(
                              fontFamily: 'ExpoArabic',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? const Color(0xFFA0A0A0)
                                  : AppColors.paragraph(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatEstimatedTime(order.estimatedTime, l10n),
                            style: AppTextStyles.body(context).copyWith(
                              fontFamily: 'ExpoArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1B1B1B),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── PROGRESS BAR: 3 segments based on status ─────────────
                Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: i < order.progressSegments
                                ? primary
                                : (isDark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (i != 2) const SizedBox(width: 4),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
