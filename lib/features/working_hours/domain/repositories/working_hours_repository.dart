import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/working_hours_entity.dart';

abstract class WorkingHoursRepository {
  /// GET /working-hours — fetch shift, days, and booking window.
  Future<Either<Failure, WorkingHoursEntity>> getWorkingHours();

  /// POST /working-hours — book a new working-hours slot.
  Future<Either<Failure, WorkingHoursEntity>> addWorkingHours({
    required String workDate, // YYYY-MM-DD
    required String startsAt, // HH:mm (24h)
    required String endsAt,   // HH:mm (24h)
  });

  /// PUT /working-hours — update a booked working-hours slot.
  Future<Either<Failure, WorkingHoursEntity>> updateWorkingHours({
    required String workDate, // YYYY-MM-DD
    required String startsAt, // HH:mm (24h)
    required String endsAt,   // HH:mm (24h)
  });

  /// DELETE /working-hours?work_date=YYYY-MM-DD — remove a booked day.
  Future<Either<Failure, WorkingHoursEntity>> deleteWorkingHours({
    required String workDate, // YYYY-MM-DD
  });
}
