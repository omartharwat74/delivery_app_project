import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/working_hours_entity.dart';
import '../../domain/repositories/working_hours_repository.dart';
import '../datasources/working_hours_remote_datasource.dart';

class WorkingHoursRepositoryImpl implements WorkingHoursRepository {
  final WorkingHoursRemoteDataSource remoteDataSource;

  WorkingHoursRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WorkingHoursEntity>> getWorkingHours() async {
    try {
      final result = await remoteDataSource.getWorkingHours();
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    try {
      final result = await remoteDataSource.addWorkingHours(
        workDate: workDate,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> deleteWorkingHours({
    required String workDate,
  }) async {
    try {
      final result = await remoteDataSource.deleteWorkingHours(
        workDate: workDate,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Object e) {
    if (e is ValidationException) {
      return ValidationFailure(e.message, errors: e.errors);
    }
    if (e is NotFoundException) {
      return NotFoundFailure(e.message);
    }
    if (e is UnauthorizedException) {
      return UnauthorizedFailure(e.message);
    }
    if (e is ForbiddenException) {
      return ForbiddenFailure(e.message);
    }
    if (e is NetworkException) {
      return NetworkFailure(e.message);
    }
    if (e is ApiException) {
      return ServerFailure(e.message, statusCode: e.statusCode);
    }
    return ServerFailure(e.toString());
  }
}
