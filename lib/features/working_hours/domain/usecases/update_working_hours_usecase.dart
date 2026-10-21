import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_entity.dart';
import '../repositories/working_hours_repository.dart';

class UpdateWorkingHoursParams extends Equatable {
  final String workDate;
  final String startsAt;
  final String endsAt;

  const UpdateWorkingHoursParams({
    required this.workDate,
    required this.startsAt,
    required this.endsAt,
  });

  @override
  List<Object?> get props => [workDate, startsAt, endsAt];
}

class UpdateWorkingHoursUseCase
    implements UseCase<WorkingHoursEntity, UpdateWorkingHoursParams> {
  final WorkingHoursRepository repository;

  UpdateWorkingHoursUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursEntity>> call(
      UpdateWorkingHoursParams params) {
    return repository.updateWorkingHours(
      workDate: params.workDate,
      startsAt: params.startsAt,
      endsAt: params.endsAt,
    );
  }
}
