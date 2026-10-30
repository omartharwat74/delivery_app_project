import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../utils/working_hours_formatters.dart';

class BookedDayCard extends StatelessWidget {
  final WorkingHourDay day;
  final DateTime selectedDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const BookedDayCard({
    super.key,
    required this.day,
    required this.selectedDate,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dayName = WorkingHoursFormatters.localizedDayName(context, selectedDate);
    final dateSlash = WorkingHoursFormatters.formatDateSlash(selectedDate);
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final period = WorkingHoursFormatters.formatShiftPeriod(
      day.startsAt,
      day.endsAt,
      isArabic: isArabic,
    );

    final isLocked = day.isLocked;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : const Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with day info and booking time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface(context),
                        fontFamily: 'ExpoArabic',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        dateSlash,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.paragraph(context),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'ExpoArabic',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actual booking time in bold
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    period,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface(context),
                      fontFamily: 'ExpoArabic',
                      fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (isLocked) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n?.lockedAppointmentWarning ??
                        'الموعد مغلق للتعديل أو الحذف (أقل من 6 ساعات)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'ExpoArabic',
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Two buttons: "تعديل الموعد" (right) and "حذف" (left)
          Row(
            children: [
              // Edit button (right)
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: l10n?.editAppointment ?? 'تعديل الموعد',
                  icon: Icons.edit_outlined,
                  backgroundColor: isLocked
                      ? (isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade100)
                      : (isDark ? const Color(0x240C9D61) : const Color(0xFFEBF8F2)),
                  foregroundColor: isLocked
                      ? (isDark ? const Color(0xFF555555) : Colors.grey.shade400)
                      : const Color(0xFF0C9D61),
                  onTap: isLocked ? null : onEdit,
                ),
              ),
              const SizedBox(width: 12),
              // Delete button (left)
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: isDeleting
                      ? (l10n?.deleting ?? 'جاري الحذف...')
                      : (l10n?.delete ?? 'حذف'),
                  icon: Icons.delete_outline_rounded,
                  backgroundColor: isLocked
                      ? (isDark ? const Color(0xFF1F1F1F) : Colors.grey.shade100)
                      : (isDark ? const Color(0x24EC2D30) : const Color(0xFFFDEBEC)),
                  foregroundColor: isLocked
                      ? (isDark ? const Color(0xFF555555) : Colors.grey.shade400)
                      : const Color(0xFFEC2D30),
                  onTap: (isLocked || isDeleting) ? null : onDelete,
                  isLoading: isDeleting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: foregroundColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                        fontFamily: 'ExpoArabic',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
