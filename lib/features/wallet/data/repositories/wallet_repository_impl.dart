import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    try {
      final result = await remoteDataSource.getWallet();
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> requestWithdrawal(double amount) async {
    try {
      await remoteDataSource.requestWithdrawal(amount);
      return const Right(null);
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
