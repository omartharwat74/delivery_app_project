import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderOfferEntity?>> getCurrentOffer();
  Future<Either<Failure, OrderEntity>> acceptOffer(int offerId);
  Future<Either<Failure, void>> rejectOffer(int offerId);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(int orderId, String status);
  Future<Either<Failure, OrdersPaginatedResponse>> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  });
  Future<Either<Failure, OrderEntity>> getOrderDetails(int orderId);
}
