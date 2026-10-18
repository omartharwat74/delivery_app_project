import '../../domain/entities/working_hours_entity.dart';

// ---------------------------------------------------------------------------
// ShiftModel
// ---------------------------------------------------------------------------

class ShiftModel extends ShiftEntity {
  const ShiftModel({required super.startsAt, required super.endsAt});

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      startsAt: json['starts_at'] as String? ?? '00:00',
      endsAt: json['ends_at'] as String? ?? '00:00',
    );
  }
}

// ---------------------------------------------------------------------------
// WorkingHourDayModel
// ---------------------------------------------------------------------------

class WorkingHourDayModel extends WorkingHourDay {
  const WorkingHourDayModel({
    required super.workDate,
    required super.startsAt,
    required super.endsAt,
    required super.isLocked,
  });

  factory WorkingHourDayModel.fromJson(Map<String, dynamic> json) {
    return WorkingHourDayModel(
      workDate: json['work_date'] as String? ?? '',
      startsAt: json['starts_at'] as String? ?? '00:00',
      endsAt: json['ends_at'] as String? ?? '00:00',
      isLocked: json['is_locked'] as bool? ?? false,
    );
  }
}

// ---------------------------------------------------------------------------
// WorkingHoursModel
// ---------------------------------------------------------------------------

class WorkingHoursModel extends WorkingHoursEntity {
  const WorkingHoursModel({
    required super.shift,
    required super.days,
    required super.windowFrom,
    required super.windowTo,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    final shiftJson = json['shift'] as Map<String, dynamic>? ?? {};
    final daysJson = json['days'] as List<dynamic>? ?? [];
    final windowJson = json['window'] as Map<String, dynamic>? ?? {};

    return WorkingHoursModel(
      shift: ShiftModel.fromJson(shiftJson),
      days: daysJson
          .map((e) => WorkingHourDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      windowFrom: windowJson['from'] as String? ?? '',
      windowTo: windowJson['to'] as String? ?? '',
    );
  }
}
