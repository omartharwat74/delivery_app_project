import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../utils/working_hours_formatters.dart';

class ShiftInfoWidget extends StatelessWidget {
  final ShiftEntity? shift;

  const ShiftInfoWidget({
    super.key,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
    if (shift == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formattedShift = WorkingHoursFormatters.formatShiftPeriod(
      shift!.startsAt,
      shift!.endsAt,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 165,
          child: Text(
            l10n?.specifiedShiftPeriod ?? 'فترة العمل المحددة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFA7A7A7) : const Color(0xFF787878),
              fontSize: 12,
              fontFamily: 'ExpoArabic',
              fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
              fontWeight: FontWeight.w400,
              height: 1.30,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 165,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              formattedShift,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: AppColors.onSurface(context),
                fontSize: 15,
                fontFamily: 'ExpoArabic',
                fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                fontWeight: FontWeight.w600,
                height: 1.40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
