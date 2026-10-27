import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository orderRepository;

  OrdersCubit({required this.orderRepository}) : super(const OrdersState());

  /// Loads the first page of orders without any scope parameter.
  Future<void> loadOrders() async {
    emit(state.copyWith(
      status: OrdersStatus.loading,
      orders: [],
      errorMessage: null,
      currentPage: 1,
      hasReachedMax: false,
    ));

    final result = await orderRepository.getOrders(
      perPage: state.perPage,
      page: 1,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: OrdersStatus.error,
          errorMessage: failure.message,
        ));
      },
      (data) {
        emit(state.copyWith(
          status: OrdersStatus.loaded,
          orders: data.items,
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          perPage: data.perPage,
          total: data.total,
          hasReachedMax: data.currentPage >= data.lastPage,
        ));
      },
    );
  }

  /// Pull-to-refresh: updates first page while keeping existing list visible until fetched.
  Future<void> refreshOrders() async {
    final result = await orderRepository.getOrders(
      perPage: state.perPage,
      page: 1,
    );

    result.fold(
      (failure) {
        // Keep existing list on pull-to-refresh failure
      },
      (data) {
        emit(state.copyWith(
          status: OrdersStatus.loaded,
          orders: data.items,
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          perPage: data.perPage,
          total: data.total,
          hasReachedMax: data.currentPage >= data.lastPage,
        ));
      },
    );
  }

  /// Pagination: fetches next page and appends to existing list.
  Future<void> loadMoreOrders() async {
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.status != OrdersStatus.loaded) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await orderRepository.getOrders(
      perPage: state.perPage,
      page: nextPage,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (data) {
        final updatedList = List.of(state.orders)..addAll(data.items);
        emit(state.copyWith(
          isLoadingMore: false,
          orders: updatedList,
          currentPage: data.currentPage,
          lastPage: data.lastPage,
          perPage: data.perPage,
          total: data.total,
          hasReachedMax: data.currentPage >= data.lastPage,
        ));
      },
    );
  }
}
