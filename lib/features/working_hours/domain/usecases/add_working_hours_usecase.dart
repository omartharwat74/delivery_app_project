import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_entity.dart';
import '../repositories/working_hours_repository.dart';

class AddWorkingHoursParams extends Equatable {
  final String workDate;
  final String startsAt;
  final String endsAt;

  const AddWorkingHoursParams({
    required this.workDate,
    required this.startsAt,
    required this.endsAt,
  });

  @override
  List<Object?> get props => [workDate, startsAt, endsAt];
}

class AddWorkingHoursUseCase
    implements UseCase<WorkingHoursEntity, AddWorkingHoursParams> {
  final WorkingHoursRepository repository;

  AddWorkingHoursUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursEntity>> call(
      AddWorkingHoursParams params) {
    return repository.addWorkingHours(
      workDate: params.workDate,
      startsAt: params.startsAt,
      endsAt: params.endsAt,
    );
  }
}
