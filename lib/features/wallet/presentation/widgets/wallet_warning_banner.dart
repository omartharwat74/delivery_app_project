import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class WalletWarningBanner extends StatelessWidget {
  final double maxDebt;

  const WalletWarningBanner({
    super.key,
    required this.maxDebt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxDebtText = maxDebt % 1 == 0
        ? maxDebt.toInt().toString()
        : maxDebt.toStringAsFixed(1);

    final title = l10n != null
        ? l10n.maxDebtLimitWarning(maxDebtText)
        : 'الحد الأعلى للمديونية عليك $maxDebtText جنيه';

    final subtitle = l10n?.maxDebtWarningDetail ??
        'في حالة الزيادة تتوقف الطلبات من الوصول إليك حتى تقوم بالسداد';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x263B82F6) // rgba(59, 130, 246, 0.15)
            : const Color(0x1A3B82F6), // rgba(59, 130, 246, 0.1)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E9EE),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Alert Icon
          SvgPicture.asset(
            'assets/icons/wallet/alert_circle.svg',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 8),
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'ExpoArabic',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: isDark
                        ? AppColors.paragraph(context)
                        : const Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
