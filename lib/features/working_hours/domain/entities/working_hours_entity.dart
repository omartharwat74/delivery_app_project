import 'package:equatable/equatable.dart';

/// Represents a single booked working-hours day for the driver.
class WorkingHourDay extends Equatable {
  final String workDate; // YYYY-MM-DD
  final String startsAt; // HH:mm (24h)
  final String endsAt;   // HH:mm (24h)
  final bool isLocked;   // true  → < 6 h until start; disables edit/delete

  const WorkingHourDay({
    required this.workDate,
    required this.startsAt,
    required this.endsAt,
    required this.isLocked,
  });

  @override
  List<Object?> get props => [workDate, startsAt, endsAt, isLocked];
}

/// Represents the driver's base shift window returned by the API.
class ShiftEntity extends Equatable {
  final String startsAt; // HH:mm (24h)
  final String endsAt;   // HH:mm (24h)

  const ShiftEntity({required this.startsAt, required this.endsAt});

  @override
  List<Object?> get props => [startsAt, endsAt];
}

/// Top-level working-hours data returned by GET /working-hours.
class WorkingHoursEntity extends Equatable {
  final ShiftEntity shift;
  final List<WorkingHourDay> days;
  final String windowFrom; // YYYY-MM-DD (first bookable day)
  final String windowTo;   // YYYY-MM-DD (last bookable day)

  const WorkingHoursEntity({
    required this.shift,
    required this.days,
    required this.windowFrom,
    required this.windowTo,
  });

  @override
  List<Object?> get props => [shift, days, windowFrom, windowTo];
}
