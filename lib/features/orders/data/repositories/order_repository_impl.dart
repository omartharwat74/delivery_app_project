import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderOfferEntity?>> getCurrentOffer() async {
    try {
      final result = await remoteDataSource.getCurrentOffer();
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> acceptOffer(int offerId) async {
    try {
      final result = await remoteDataSource.acceptOffer(offerId);
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> rejectOffer(int offerId) async {
    try {
      await remoteDataSource.rejectOffer(offerId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(int orderId, String status) async {
    try {
      final result = await remoteDataSource.updateOrderStatus(orderId, status);
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OrdersPaginatedResponse>> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.getOrders(
        scope: scope,
        perPage: perPage,
        page: page,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId) async {
    try {
      final result = await remoteDataSource.getOrderDetails(orderId);
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
