import 'package:flutter/widgets.dart';

class WorkingHoursFormatters {
  WorkingHoursFormatters._();

  /// Converts a 24-hour time string ("09:00" or "13:30" or "09:00:00")
  /// to 12-hour format e.g. "09:00 AM" or "01:30 PM".
  static String format12Hour(String? time24) {
    if (time24 == null || time24.isEmpty) return '';

    final clean = time24.trim();
    // If it already contains AM or PM, return it
    if (clean.toUpperCase().contains('AM') || clean.toUpperCase().contains('PM')) {
      return clean;
    }

    final parts = clean.split(':');
    if (parts.length < 2) return clean;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final period = hour >= 12 ? 'PM' : 'AM';
    var hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr $period';
  }

  /// Formats start and end times into "09:00 AM - 12:00 PM".
  static String formatShiftPeriod(String? startsAt, String? endsAt) {
    final startFormatted = format12Hour(startsAt);
    final endFormatted = format12Hour(endsAt);
    if (startFormatted.isEmpty && endFormatted.isEmpty) return '';
    return '$startFormatted - $endFormatted';
  }

  /// Formats date to DD/MM/YYYY
  static String formatDateSlash(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  /// Formats date to YYYY-MM-DD (API standard)
  static String formatDateDash(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Localized day name based on current BuildContext
  static String localizedDayName(BuildContext context, DateTime date) {
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    if (isArabic) {
      return arabicDayName(date);
    }
    return englishDayName(date);
  }

  /// English day of the week name
  static String englishDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      default:
        return '';
    }
  }

  /// Arabic day of the week name
  static String arabicDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الاثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  /// Localized month name based on current BuildContext
  static String localizedMonthName(BuildContext context, int month) {
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    if (isArabic) {
      return arabicMonthName(month);
    }
    return englishMonthName(month);
  }

  /// English month name
  static String englishMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  /// Arabic month name
  static String arabicMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  /// Converts TimeOfDay to "HH:mm" (24-hour)
  static String timeOfDayTo24h(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
