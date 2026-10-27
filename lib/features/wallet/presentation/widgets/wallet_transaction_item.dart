import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wallet_transaction_entity.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletTransactionEntity transaction;

  const WalletTransactionItem({
    super.key,
    required this.transaction,
  });

  String _formatDate(String? rawDate, String locale) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('d MMMM yyyy', locale).format(parsed);
      }
    } catch (_) {}
    return rawDate;
  }

  String _formatAmount(double amount, String locale) {
    final absAmount = amount.abs();
    final formatter = NumberFormat('#,##0.##', locale);
    return formatter.format(absAmount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final source = transaction.source;
    final status = transaction.status?.toLowerCase();
    final isPending = transaction.isPending ||
        source == 'pending_withdrawal' ||
        status == 'pending';

    final isWithdrawal = source == 'pending_withdrawal' ||
        source == 'withdraw_hold' ||
        transaction.title == 'طلب سحب' ||
        (l10n != null && transaction.title == l10n.withdrawalRequest);

    // ── Determine Status Badge, Colors, and Icons ──────────────────────────
    String? badgeText;
    Color? badgeTextColor;
    Color? badgeBgColor;

    Color amountColor;
    Color iconBgColor;
    Color? iconColor;
    String iconAsset;
    String title = transaction.title ?? '';
    String? description = transaction.description;

    if (isWithdrawal) {
      title = l10n?.withdrawalRequest ?? 'طلب سحب';
      amountColor = const Color(0xFFEC2D30); // Red
      iconAsset = 'assets/icons/wallet/arrow_up_left.svg';

      if (status == 'completed' || status == 'done' || status == 'success') {
        // حالة: منتهي (#0C9D61 · 10% للخلفية، و#0C9D61 للسهم ونص الحالة)
        badgeText = l10n?.completedBadge ?? 'منتهي';
        iconBgColor = const Color(0x1A0C9D61);
        iconColor = const Color(0xFF0C9D61);
        badgeBgColor = const Color(0x1A0C9D61);
        badgeTextColor = const Color(0xFF0C9D61);
      } else if (status == 'rejected' || status == 'failed' || status == 'cancelled') {
        // حالة: مرفوض (#EC2D30 · 10% للخلفية، و#EC2D30 للسهم ونص الحالة)
        badgeText = l10n?.rejectedBadge ?? 'مرفوض';
        iconBgColor = const Color(0x1AEC2D30);
        iconColor = const Color(0xFFEC2D30);
        badgeBgColor = const Color(0x1AEC2D30);
        badgeTextColor = const Color(0xFFEC2D30);
      } else if (isPending || status == 'pending') {
        // حالة: قيد المراجعة (#F1D060 · 20% للخلفية، و#EFBE1C للسهم ونص الحالة)
        badgeText = l10n?.pendingReviewBadge ?? 'قيد المراجعة';
        iconBgColor = const Color(0x33F1D060);
        iconColor = const Color(0xFFEFBE1C);
        badgeBgColor = const Color(0x33F1D060);
        badgeTextColor = const Color(0xFFEFBE1C);
      } else {
        // حالة افتراضية لطلب السحب: قيد المراجعة
        badgeText = l10n?.pendingReviewBadge ?? 'قيد المراجعة';
        iconBgColor = const Color(0x33F1D060);
        iconColor = const Color(0xFFEFBE1C);
        badgeBgColor = const Color(0x33F1D060);
        badgeTextColor = const Color(0xFFEFBE1C);
      }
    } else {
      switch (source) {
        case 'order_cash_debt':
          title = l10n?.cashOrder ?? 'طلب كاش';
          description = l10n?.appCommission ?? (description ?? 'عمولة التطبيق');
          amountColor = const Color(0xFFEC2D30); // Red
          iconBgColor = const Color(0x33F1D060); // rgba(241, 208, 96, 0.2)
          iconAsset = 'assets/icons/wallet/money_send_flow.svg';
          iconColor = null;
          break;
        case 'order_earning':
          title = l10n?.cardOrder ?? 'طلب فيزا';
          description = l10n?.deliveryFee ?? (description ?? 'رسوم التوصيل');
          amountColor = const Color(0xFF0C9D61); // Green
          iconBgColor = const Color(0x1A0C9D61); // rgba(12, 157, 97, 0.1)
          iconAsset = 'assets/icons/wallet/money_add.svg';
          iconColor = null;
          break;
        case 'cash_received':
          title = l10n?.debtSettlement ?? 'تسديد مديونية';
          amountColor = const Color(0xFF3B82F6); // Blue
          iconBgColor = const Color(0x1A3B82F6); // rgba(59, 130, 246, 0.1)
          iconAsset = 'assets/icons/wallet/money_send.svg';
          iconColor = null;
          break;
        default:
          if (transaction.amount < 0) {
            amountColor = const Color(0xFFEC2D30);
            iconBgColor = const Color(0x1AEC2D30);
            iconAsset = 'assets/icons/wallet/arrow_up_left.svg';
            iconColor = const Color(0xFFEC2D30);
          } else {
            amountColor = const Color(0xFF0C9D61);
            iconBgColor = const Color(0x1A0C9D61);
            iconAsset = 'assets/icons/wallet/money_add.svg';
            iconColor = null;
          }
      }
    }

    final formattedDate = _formatDate(transaction.createdAt, locale);
    final currency = l10n?.currencyEgp ?? 'ج.م';
    final sign = transaction.amount < 0 ? '-' : '+';
    final formattedAmount = _formatAmount(transaction.amount, locale);

    // ── Build Icon Widget (with arrow flipping for RTL vs LTR) ──────────────
    final isArrowIcon = iconAsset.contains('arrow');
    Widget iconWidget = SvgPicture.asset(
      iconAsset,
      width: 24,
      height: 24,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    );

    // In Arabic (RTL), arrow points up-right (flipped). In English (LTR), it remains up-left.
    if (isArrowIcon && isRtl) {
      iconWidget = Transform.flip(
        flipX: true,
        child: iconWidget,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading: Icon & Details ──────────────────────────────
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(7),
            child: iconWidget,
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Row (with pending badge if applicable)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: AppColors.onSurface(context),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: badgeTextColor,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle Row: Date • Description • OrderId
                _buildSubtitleRow(context, formattedDate, description, transaction.orderId),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Trailing: Amount & Currency (Sign first, Amount middle, Currency last) ──
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                sign,
                style: TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                formattedAmount,
                style: TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleRow(
    BuildContext context,
    String formattedDate,
    String? description,
    String? orderId,
  ) {
    final List<Widget> items = [];

    if (orderId != null && orderId.isNotEmpty) {
      final cleanId = orderId.startsWith('#') ? orderId : '#$orderId';
      items.add(
        Text(
          cleanId,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.paragraph(context),
            height: 1.25,
          ),
        ),
      );
    }

    if (description != null && description.isNotEmpty) {
      if (items.isNotEmpty) items.add(_dotSeparator(context));
      items.add(
        Text(
          description,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.paragraph(context),
            height: 1.25,
          ),
        ),
      );
    }

    if (formattedDate.isNotEmpty) {
      if (items.isNotEmpty) items.add(_dotSeparator(context));
      items.add(
        Text(
          formattedDate,
          style: TextStyle(
            fontFamily: 'ExpoArabic',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.paragraph(context),
            height: 1.25,
          ),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items,
    );
  }

  Widget _dotSeparator(BuildContext context) {
    return Container(
      width: 2,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.paragraph(context),
        shape: BoxShape.circle,
      ),
    );
  }
}
