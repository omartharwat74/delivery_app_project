import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback? onWithdrawPressed;

  const WalletBalanceCard({
    super.key,
    required this.wallet,
    this.onWithdrawPressed,
  });

  String _formatAmount(double amount, String locale) {
    final formatter = NumberFormat('#,##0.##', locale);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final availableBalance = wallet.availableBalance;
    final debt = wallet.debt;
    final maxDebt = wallet.maxDebt;
    final canWithdraw = wallet.canWithdraw;
    final currency = l10n?.currencyEgp ?? 'ج.م';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Top Row: Available Balance + Wallet SVG ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Balance Info Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n?.availableBalanceToWithdraw ?? 'الرصيد المتاح للسحب',
                    style: TextStyle(
                      fontFamily: 'ExpoArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      color: AppColors.paragraph(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatAmount(availableBalance, locale)} $currency',
                    style: TextStyle(
                      fontFamily: 'ExpoArabic',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.onSurface(context),
                    ),
                  ),
                ],
              ),
              // Wallet Icon (54x54)
              SvgPicture.asset(
                'assets/icons/wallet/wallet_icon.svg',
                width: 54,
                height: 54,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── 2. Debt Info Row: Titles & Values ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: "المديونية (كاش معاك)"
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l10n?.debtTitle ?? 'المديونية',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface(context),
                        height: 1.3,
                      ),
                    ),
                    TextSpan(
                      text: l10n?.cashWithYou ?? '  (كاش معاك)',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.paragraph(context),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              // Value: "380 ج.م / 500 ج.م"
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_formatAmount(debt, locale)} $currency',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface(context),
                        height: 1.3,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${_formatAmount(maxDebt, locale)} $currency',
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.paragraph(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── 3. Progress Bar ─────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final ratio = wallet.debtRatio;
              final progressWidth = (trackWidth * ratio).clamp(0.0, trackWidth);

              return Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: progressWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── 4. Withdraw Button ──────────────────────────────────────────
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canWithdraw ? onWithdrawPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFFFFFFFF),
                disabledBackgroundColor: isDark
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.35),
                disabledForegroundColor:
                    const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n?.withdrawBalanceButton ?? 'سحب الرصيد',
                style: const TextStyle(
                  fontFamily: 'ExpoArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
