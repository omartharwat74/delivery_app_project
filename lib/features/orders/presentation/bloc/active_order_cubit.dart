import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/order_repository.dart';
import 'active_order_state.dart';

class ActiveOrderCubit extends Cubit<ActiveOrderState> {
  final OrderRepository orderRepository;

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  int get remainingSeconds => _remainingSeconds;

  ActiveOrderCubit({required this.orderRepository})
      : super(const ActiveOrderIdle());

  /// 1. State Restoration:
  /// Checks if driver has an ongoing assigned or on_the_way order.
  /// If not, checks if an offer is currently waiting.
  Future<void> restoreActiveOrderOrOffer() async {
    cancelTimers();

    // 1. Check current assigned / on_the_way orders
    final currentOrdersResult =
        await orderRepository.getOrders(scope: 'current', perPage: 5, page: 1);

    final currentOrder = currentOrdersResult.fold(
      (_) => null,
      (paginated) {
        if (paginated.items.isNotEmpty) {
          final first = paginated.items.first;
          if (first.status == 'assigned' || first.status == 'on_the_way') {
            return first;
          }
        }
        return null;
      },
    );

    if (currentOrder != null) {
      emit(ActiveOrderInProgress(order: currentOrder));
      return;
    }

    // 2. Check waiting offer
    await checkCurrentOffer();
  }

  /// 2. Check current offer from server (e.g. on FCM chime or foreground poll).
  Future<void> checkCurrentOffer() async {
    // If driver is currently executing an active order, do not overwrite with an offer
    if (state is ActiveOrderInProgress) {
      return;
    }

    final offerResult = await orderRepository.getCurrentOffer();

    offerResult.fold(
      (_) {
        if (state is ActiveOrderOfferReceived) {
          cancelTimers();
          emit(const ActiveOrderIdle());
        }
      },
      (offer) {
        if (offer != null && offer.secondsLeft > 0) {
          // If we are already on this offer, just sync remaining seconds
          if (state is ActiveOrderOfferReceived &&
              (state as ActiveOrderOfferReceived).offer.id == offer.id) {
            _remainingSeconds = offer.secondsLeft;
          } else {
            emit(ActiveOrderOfferReceived(offer: offer));
            _startOfferTimers(offer.secondsLeft);
          }
        } else {
          if (state is ActiveOrderOfferReceived) {
            cancelTimers();
            emit(const ActiveOrderIdle());
          }
        }
      },
    );
  }

  /// 3. Accept current offer (Stage 1 -> Stage 2)
  Future<void> acceptOffer() async {
    final currentState = state;
    if (currentState is! ActiveOrderOfferReceived || currentState.isAccepting) {
      return;
    }

    // Temporarily disable polling to prevent race conditions during accept
    _pollingTimer?.cancel();
    emit(currentState.copyWith(isAccepting: true));

    final result = await orderRepository.acceptOffer(currentState.offer.id);

    result.fold(
      (failure) {
        cancelTimers();
        // 404 or 422: offer no longer available
        emit(
          ActiveOrderActionError(
            message: failure.message,
            nextState: const ActiveOrderIdle(),
          ),
        );
      },
      (acceptedOrder) {
        cancelTimers();
        emit(ActiveOrderInProgress(order: acceptedOrder));
      },
    );
  }

  /// 4. Confirm pickup: transition from assigned -> on_the_way (Stage 2 -> Stage 3)
  Future<void> confirmPickup() async {
    final currentState = state;
    if (currentState is! ActiveOrderInProgress ||
        !currentState.isAssigned ||
        currentState.isUpdatingStatus) {
      return;
    }

    emit(currentState.copyWith(isUpdatingStatus: true));

    final result = await orderRepository.updateOrderStatus(
      currentState.order.id,
      'on_the_way',
    );

    result.fold(
      (failure) {
        emit(
          ActiveOrderActionError(
            message: failure.message,
            nextState: currentState.copyWith(isUpdatingStatus: false),
          ),
        );
        _refreshOrderDetails(currentState.order.id);
      },
      (updatedOrder) {
        emit(ActiveOrderInProgress(order: updatedOrder));
      },
    );
  }

  /// 5. Confirm delivery: transition from on_the_way -> delivered (Stage 3 -> Idle)
  Future<void> confirmDelivery() async {
    final currentState = state;
    if (currentState is! ActiveOrderInProgress ||
        !currentState.isOnTheWay ||
        currentState.isUpdatingStatus) {
      return;
    }

    emit(currentState.copyWith(isUpdatingStatus: true));

    final result = await orderRepository.updateOrderStatus(
      currentState.order.id,
      'delivered',
    );

    result.fold(
      (failure) {
        emit(
          ActiveOrderActionError(
            message: failure.message,
            nextState: currentState.copyWith(isUpdatingStatus: false),
          ),
        );
        _refreshOrderDetails(currentState.order.id);
      },
      (_) {
        // Order completed successfully; driver is now free
        emit(const ActiveOrderIdle());
      },
    );
  }

  Future<void> _refreshOrderDetails(int orderId) async {
    final res = await orderRepository.getOrderDetails(orderId);
    res.fold(
      (_) {},
      (order) {
        if (order.status == 'delivered') {
          emit(const ActiveOrderIdle());
        } else if (order.status == 'assigned' || order.status == 'on_the_way') {
          emit(ActiveOrderInProgress(order: order));
        }
      },
    );
  }

  void _startOfferTimers(int secondsLeft) {
    cancelTimers();
    _remainingSeconds = secondsLeft;

    // 1-second countdown timer to dismiss offer when local time expires
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        cancelTimers();
        emit(const ActiveOrderIdle());
        // Verify with server
        checkCurrentOffer();
      }
    });

    // 5-second polling timer per Section 3 requirement
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final res = await orderRepository.getCurrentOffer();
      res.fold(
        (_) {},
        (offer) {
          if (offer == null) {
            cancelTimers();
            emit(const ActiveOrderIdle());
          } else if (offer.secondsLeft < _remainingSeconds) {
            _remainingSeconds = offer.secondsLeft;
          }
        },
      );
    });
  }

  void cancelTimers() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  @override
  Future<void> close() {
    cancelTimers();
    return super.close();
  }
}
