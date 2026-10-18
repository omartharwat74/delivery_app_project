import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_entity.dart';
import '../repositories/working_hours_repository.dart';

class DeleteWorkingHoursParams extends Equatable {
  final String workDate;

  const DeleteWorkingHoursParams({required this.workDate});

  @override
  List<Object?> get props => [workDate];
}

class DeleteWorkingHoursUseCase
    implements UseCase<WorkingHoursEntity, DeleteWorkingHoursParams> {
  final WorkingHoursRepository repository;

  DeleteWorkingHoursUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursEntity>> call(
      DeleteWorkingHoursParams params) {
    return repository.deleteWorkingHours(workDate: params.workDate);
  }
}
