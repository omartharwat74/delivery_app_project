import 'package:equatable/equatable.dart';

import '../../domain/entities/working_hours_entity.dart';

// ---------------------------------------------------------------------------
// Enum: which "card mode" is currently shown below the calendar
// ---------------------------------------------------------------------------

/// The four UI states of the card section below the calendar.
enum WorkingHoursCardMode {
  /// No day selected – only the base shift label is visible, no card/button.
  initial,

  /// User tapped an unbooked day in the 7-day window → show time pickers + "تأكيد".
  newBooking,

  /// User tapped a booked day → show the booking detail card (no bottom button).
  bookedView,

  /// User tapped "تعديل الموعد" inside the detail card → show edit pickers + "تأكيد التعديل".
  editBooking,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class WorkingHoursState extends Equatable {
  // ── Server data ────────────────────────────────────────────────────────────
  final WorkingHoursEntity? data;
  final bool isLoading;
  final bool isActionLoading; // true while POST / DELETE in flight

  // ── Error / success messages (transient) ──────────────────────────────────
  final String? errorMessage;
  final String? successMessage;

  // ── Calendar selection ────────────────────────────────────────────────────
  /// The date currently highlighted in the calendar (null = none selected).
  final DateTime? selectedDate;

  /// Calendar display month (only month + year matter).
  final DateTime displayMonth;

  // ── Card UI mode ──────────────────────────────────────────────────────────
  final WorkingHoursCardMode cardMode;

  // ── Time-picker values (used in newBooking + editBooking) ─────────────────
  /// HH:mm (24h) strings as picked by the user; null until user picks.
  final String? pickedStartsAt;
  final String? pickedEndsAt;

  const WorkingHoursState({
    this.data,
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
    this.successMessage,
    this.selectedDate,
    required this.displayMonth,
    this.cardMode = WorkingHoursCardMode.initial,
    this.pickedStartsAt,
    this.pickedEndsAt,
  });

  WorkingHoursState copyWith({
    WorkingHoursEntity? data,
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    DateTime? displayMonth,
    WorkingHoursCardMode? cardMode,
    String? pickedStartsAt,
    bool clearPickedStartsAt = false,
    String? pickedEndsAt,
    bool clearPickedEndsAt = false,
  }) {
    return WorkingHoursState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      displayMonth: displayMonth ?? this.displayMonth,
      cardMode: cardMode ?? this.cardMode,
      pickedStartsAt:
          clearPickedStartsAt ? null : (pickedStartsAt ?? this.pickedStartsAt),
      pickedEndsAt:
          clearPickedEndsAt ? null : (pickedEndsAt ?? this.pickedEndsAt),
    );
  }

  /// Convenience: list of booked dates as DateTime objects.
  List<DateTime> get bookedDates {
    return data?.days
            .map((d) => DateTime.tryParse(d.workDate))
            .whereType<DateTime>()
            .toList() ??
        [];
  }

  /// Convenience: start of the bookable 7-day window.
  DateTime? get windowStart =>
      data != null ? DateTime.tryParse(data!.windowFrom) : null;

  /// Convenience: end of the bookable 7-day window.
  DateTime? get windowEnd =>
      data != null ? DateTime.tryParse(data!.windowTo) : null;

  /// Whether the given date falls inside the bookable window.
  bool isInWindow(DateTime date) {
    final from = windowStart;
    final to = windowEnd;
    if (from == null || to == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return !d.isBefore(f) && !d.isAfter(t);
  }

  /// Whether the given date is already booked.
  bool isBooked(DateTime date) {
    final key =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return data?.days.any((d) => d.workDate == key) ?? false;
  }

  /// Return the [WorkingHourDay] for a booked date, or null.
  WorkingHourDay? bookedDayFor(DateTime date) {
    final key =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return data?.days.firstWhere((d) => d.workDate == key);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        data,
        isLoading,
        isActionLoading,
        errorMessage,
        successMessage,
        selectedDate,
        displayMonth,
        cardMode,
        pickedStartsAt,
        pickedEndsAt,
      ];
}
