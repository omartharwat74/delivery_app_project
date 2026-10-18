import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../utils/working_hours_formatters.dart';

class _AmPmCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AmPmCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(const _AmPmCupertinoLocalizations());

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}

class _AmPmCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const _AmPmCupertinoLocalizations();

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get postMeridiemAbbreviation => 'PM';
}

class TimeRangePickerWidget extends StatelessWidget {
  final String dayName;
  final String? startsAt;
  final String? endsAt;
  final ShiftEntity? shift;
  final Function(String startsAt, String endsAt) onTimesChanged;
  final Function(String errorMessage)? onError;

  const TimeRangePickerWidget({
    super.key,
    required this.dayName,
    required this.startsAt,
    required this.endsAt,
    required this.shift,
    required this.onTimesChanged,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day name on the right
        if (dayName.isNotEmpty) ...[
          Text(
            dayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface(context),
              fontFamily: 'ExpoArabic',
              fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Two time pickers: "من" (right) and "الى" (left)
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                context: context,
                label: l10n?.fromTime ?? 'من',
                timeValue: startsAt,
                isStart: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                context: context,
                label: l10n?.toTime ?? 'الى',
                timeValue: endsAt,
                isStart: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required String? timeValue,
    required bool isStart,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTime = timeValue != null && timeValue.isNotEmpty
        ? WorkingHoursFormatters.format12Hour(timeValue)
        : '--:--';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _pickTime(context, isStart),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkOutline : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFA7A7A7) : Colors.grey.shade600,
                fontFamily: 'ExpoArabic',
                fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  displayTime,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface(context),
                    fontFamily: 'ExpoArabic',
                    fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Icon(
              Icons.access_time_rounded,
              size: 20,
              color: isDark ? const Color(0xFFA7A7A7) : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentTimeStr = isStart ? startsAt : endsAt;
    final initialTime = _parseTimeOfDay(currentTimeStr) ??
        (isStart
            ? _parseTimeOfDay(shift?.startsAt) ?? const TimeOfDay(hour: 9, minute: 0)
            : _parseTimeOfDay(shift?.endsAt) ?? const TimeOfDay(hour: 17, minute: 0));

    final baseDate = DateTime(2026, 1, 1);
    var initialDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      initialTime.hour,
      initialTime.minute,
    );

    // Calculate shift bounds
    DateTime? minDateTime;
    DateTime? maxDateTime;

    if (shift != null) {
      final start = _parseTimeOfDay(shift!.startsAt);
      final end = _parseTimeOfDay(shift!.endsAt);
      if (start != null && end != null) {
        final startDt = DateTime(baseDate.year, baseDate.month, baseDate.day, start.hour, start.minute);
        final endDt = DateTime(baseDate.year, baseDate.month, baseDate.day, end.hour, end.minute);
        if (startDt.isBefore(endDt)) {
          minDateTime = startDt;
          maxDateTime = endDt;
        }
      }
    }

    // Constrain: start time cannot exceed endsAt (if selected), end time cannot precede startsAt (if selected)
    if (isStart) {
      final end = _parseTimeOfDay(endsAt);
      if (end != null) {
        final endDt = DateTime(baseDate.year, baseDate.month, baseDate.day, end.hour, end.minute);
        if (maxDateTime == null || endDt.isBefore(maxDateTime)) {
          maxDateTime = endDt;
        }
      }
    } else {
      final start = _parseTimeOfDay(startsAt);
      if (start != null) {
        final startDt = DateTime(baseDate.year, baseDate.month, baseDate.day, start.hour, start.minute);
        if (minDateTime == null || startDt.isAfter(minDateTime)) {
          minDateTime = startDt;
        }
      }
    }

    // Clamp initialDateTime so it always falls strictly within [minDateTime, maxDateTime]
    if (minDateTime != null && initialDateTime.isBefore(minDateTime)) {
      initialDateTime = minDateTime;
    }
    if (maxDateTime != null && initialDateTime.isAfter(maxDateTime)) {
      initialDateTime = maxDateTime;
    }

    DateTime selectedDateTime = initialDateTime;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 290,
            child: Column(
              children: [
                // Top bar with Cancel ("إلغاء"), Title, and Confirm ("تأكيد")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          l10n?.cancel ?? 'إلغاء',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? const Color(0xFFA7A7A7) : Colors.grey.shade600,
                            fontFamily: 'ExpoArabic',
                            fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                          ),
                        ),
                      ),
                      Text(
                        isStart
                            ? (l10n?.selectStartTimeTitle ?? 'تحديد وقت البداية (من)')
                            : (l10n?.selectEndTimeTitle ?? 'تحديد وقت النهاية (الى)'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface(sheetContext),
                          fontFamily: 'ExpoArabic',
                          fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          final picked24h = WorkingHoursFormatters.timeOfDayTo24h(
                            selectedDateTime.hour,
                            selectedDateTime.minute,
                          );
                          if (isStart) {
                            onTimesChanged(picked24h, endsAt ?? '');
                          } else {
                            onTimesChanged(startsAt ?? '', picked24h);
                          }
                        },
                        child: Text(
                          l10n?.confirm ?? 'تأكيد',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'ExpoArabic',
                            fontFamilyFallback: ['Expo Arabic', 'ExpoArabic'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkOutline : const Color(0xFFF0F0F0),
                ),

                // Native iOS Cupertino Wheel Time Picker (Hours on left, Minutes on right, AM/PM)
                Expanded(
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        pickerTextStyle: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                          fontSize: 21,
                        ),
                      ),
                    ),
                    child: Localizations.override(
                      context: sheetContext,
                      locale: const Locale('en'),
                      delegates: const [_AmPmCupertinoLocalizationsDelegate()],
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: false,
                          initialDateTime: initialDateTime,
                          minimumDate: minDateTime,
                          maximumDate: maxDateTime,
                          onDateTimeChanged: (DateTime newDateTime) {
                            selectedDateTime = newDateTime;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
