import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/working_hours_entity.dart';
import 'time_range_picker_widget.dart';

class EditBookingCard extends StatelessWidget {
  final DateTime selectedDate;
  final String? startsAt;
  final String? endsAt;
  final ShiftEntity? shift;
  final Function(String startsAt, String endsAt) onTimesChanged;
  final VoidCallback onCancel;
  final Function(String errorMessage)? onError;

  const EditBookingCard({
    super.key,
    required this.selectedDate,
    required this.startsAt,
    required this.endsAt,
    required this.shift,
    required this.onTimesChanged,
    required this.onCancel,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Top Header: "تعديل الموعد" with close/cancel button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.editAppointment ?? 'تعديل الموعد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface(context),
                  fontFamily: 'ExpoArabic',
                ),
              ),
              InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.paragraph(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two time fields: "من" and "الى" prefilled
          TimeRangePickerWidget(
            dayName: '',
            startsAt: startsAt,
            endsAt: endsAt,
            shift: shift,
            onTimesChanged: onTimesChanged,
            onError: onError,
          ),
        ],
      ),
    );
  }
}
