import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        currentPage,
        lastPage,
        perPage,
        total,
        hasReachedMax,
        isLoadingMore,
        errorMessage,
      ];
}
