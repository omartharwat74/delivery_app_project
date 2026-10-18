import 'package:delivery_app_project/features/working_hours/data/models/working_hours_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkingHoursModel', () {
    const mockJson = {
      'shift': {
        'starts_at': '09:00',
        'ends_at': '17:00',
      },
      'days': [
        {
          'work_date': '2026-11-18',
          'starts_at': '09:00',
          'ends_at': '13:00',
          'is_locked': false,
        },
        {
          'work_date': '2026-11-19',
          'starts_at': '10:00',
          'ends_at': '15:00',
          'is_locked': true,
        },
      ],
      'window': {
        'from': '2026-11-18',
        'to': '2026-11-24',
      },
    };

    test('parses json correctly into WorkingHoursModel', () {
      final model = WorkingHoursModel.fromJson(mockJson);

      expect(model.shift.startsAt, '09:00');
      expect(model.shift.endsAt, '17:00');
      expect(model.windowFrom, '2026-11-18');
      expect(model.windowTo, '2026-11-24');
      expect(model.days.length, 2);

      final day1 = model.days[0];
      expect(day1.workDate, '2026-11-18');
      expect(day1.startsAt, '09:00');
      expect(day1.endsAt, '13:00');
      expect(day1.isLocked, false);

      final day2 = model.days[1];
      expect(day2.workDate, '2026-11-19');
      expect(day2.isLocked, true);
    });

    test('handles missing or empty fields with sensible defaults', () {
      final model = WorkingHoursModel.fromJson(const {});

      expect(model.shift.startsAt, '00:00');
      expect(model.shift.endsAt, '00:00');
      expect(model.windowFrom, '');
      expect(model.windowTo, '');
      expect(model.days, isEmpty);
    });
  });
}
