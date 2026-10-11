import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_registration.dart';
import '../repositories/auth_repository.dart';

class RegisterDriverUseCase
    implements UseCase<DriverRegistration, RegisterDriverParams> {
  RegisterDriverUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, DriverRegistration>> call(
    RegisterDriverParams params,
  ) {
    return _repository.registerDriverLegacy(params);
  }
}
