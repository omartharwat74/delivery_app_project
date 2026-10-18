import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_entity.dart';
import '../repositories/working_hours_repository.dart';

class GetWorkingHoursUseCase implements UseCase<WorkingHoursEntity, NoParams> {
  final WorkingHoursRepository repository;

  GetWorkingHoursUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursEntity>> call(NoParams params) {
    return repository.getWorkingHours();
  }
}
