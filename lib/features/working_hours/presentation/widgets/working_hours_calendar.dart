import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/working_hours_state.dart';
import '../utils/working_hours_formatters.dart';

class WorkingHoursCalendar extends StatelessWidget {
  final WorkingHoursState state;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<int> onMonthChanged;

  const WorkingHoursCalendar({
    super.key,
    required this.state,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMonth = state.displayMonth;
    final monthName = WorkingHoursFormatters.localizedMonthName(context, displayMonth.month);

    // Weekday names Sun -> Sat in LTR order
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Generate weeks of 7 days each
    final weeks = _generateWeeks(displayMonth);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.darkOutline : const Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header: month navigation (chevron_left on left, month in center, chevron_right on right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_left_rounded,
                  onTap: () => onMonthChanged(-1),
                ),
                Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface(context),
                    fontFamily: 'ExpoArabic',
                    fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                  ),
                ),
                _buildNavButton(
                  context: context,
                  icon: Icons.chevron_right_rounded,
                  onTap: () => onMonthChanged(1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weekdays header (Sun -> Sat from left to right)
            Row(
              children: weekDays
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFA7A7A7) : const Color(0xFF787878),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'ExpoArabic',
                              fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Weekly rows with continuous range background
            Column(
              children: List.generate(weeks.length, (weekIndex) {
                final week = weeks[weekIndex];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: weekIndex < weeks.length - 1 ? 8.0 : 0.0,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: List.generate(7, (col) {
                        final cell = week[col];
                        return Expanded(
                          child: _buildDayCell(
                            context: context,
                            cell: cell,
                            col: col,
                            week: week,
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkOutline : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: AppColors.onSurface(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required _CalendarDayCell cell,
    required int col,
    required List<_CalendarDayCell> week,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!cell.isCurrentMonth) {
      return Center(
        child: Text(
          cell.date.day.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            fontFamily: 'ExpoArabic',
            fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
          ),
        ),
      );
    }

    final inWindow = state.isInWindow(cell.date);
    final isBooked = state.isBooked(cell.date);
    final isSelected = state.selectedDate != null &&
        _isSameDay(state.selectedDate!, cell.date);

    // Calculate whether previous and next days in the same week row are also in window
    final prevInWindow = col > 0 &&
        week[col - 1].isCurrentMonth &&
        state.isInWindow(week[col - 1].date);
    final nextInWindow = col < 6 &&
        week[col + 1].isCurrentMonth &&
        state.isInWindow(week[col + 1].date);

    // Continuous strip border radius:
    // Rounded on left only if this is the start of range or col == 0
    // Rounded on right only if this is the end of range or col == 6
    BorderRadius stripBorderRadius = BorderRadius.zero;
    if (inWindow) {
      final roundLeft = !prevInWindow;
      final roundRight = !nextInWindow;

      if (roundLeft && roundRight) {
        stripBorderRadius = BorderRadius.circular(8);
      } else if (roundLeft) {
        stripBorderRadius = const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        );
      } else if (roundRight) {
        stripBorderRadius = const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      }
    }

    final stripColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFE5E7EB); // Continuous grey background from Figma

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: inWindow ? () => onDateSelected(cell.date) : null,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: inWindow ? stripColor : Colors.transparent,
          borderRadius: stripBorderRadius,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // If selected: render green rounded box on top of the strip
            if (isSelected)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C9D61),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

            // Date text
            Text(
              cell.date.day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: (inWindow || isSelected)
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (inWindow
                        ? AppColors.onSurface(context)
                        : (isDark
                            ? const Color(0xFF777777)
                            : const Color(0xFF1B1B1B))),
                fontFamily: 'ExpoArabic',
                fontFamilyFallback: const ['Expo Arabic', 'ExpoArabic'],
              ),
            ),

            // Small indicator dot for booked day when not selected
            if (isBooked && !isSelected)
              Positioned(
                bottom: 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C9D61),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<List<_CalendarDayCell>> _generateWeeks(DateTime monthDate) {
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final totalDays = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    // Sunday = 7 in Dart DateTime.weekday. Sunday % 7 = 0
    final startOffset = firstDay.weekday % 7;

    final prevMonthTotalDays =
        DateTime(monthDate.year, monthDate.month, 0).day;

    final List<_CalendarDayCell> flatList = [];

    // Leading days from previous month
    for (int i = startOffset - 1; i >= 0; i--) {
      final prevDate = DateTime(
        monthDate.year,
        monthDate.month - 1,
        prevMonthTotalDays - i,
      );
      flatList.add(_CalendarDayCell(date: prevDate, isCurrentMonth: false));
    }

    // Current month days
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(monthDate.year, monthDate.month, day);
      flatList.add(_CalendarDayCell(date: date, isCurrentMonth: true));
    }

    // Trailing days from next month to complete multiples of 7
    final remainder = flatList.length % 7;
    if (remainder != 0) {
      final needed = 7 - remainder;
      for (int day = 1; day <= needed; day++) {
        final nextDate = DateTime(monthDate.year, monthDate.month + 1, day);
        flatList.add(_CalendarDayCell(date: nextDate, isCurrentMonth: false));
      }
    }

    // Group into weeks of 7
    final List<List<_CalendarDayCell>> weeks = [];
    for (int i = 0; i < flatList.length; i += 7) {
      weeks.add(flatList.sublist(i, i + 7));
    }

    return weeks;
  }
}

class _CalendarDayCell {
  final DateTime date;
  final bool isCurrentMonth;

  _CalendarDayCell({required this.date, required this.isCurrentMonth});
}
