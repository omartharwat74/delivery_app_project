import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../domain/repositories/order_repository.dart';
import 'active_order_state.dart';

class ActiveOrderCubit extends Cubit<ActiveOrderState> {
  final OrderRepository orderRepository;
  final LocaleController? localeController;
  VoidCallback? _localeListener;

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Timer? _fallbackPollingTimer;
  int _remainingSeconds = 0;

  int get remainingSeconds => _remainingSeconds;
  bool get isPollingActive => _pollingTimer != null && _pollingTimer!.isActive;
  bool get isFallbackPollingActive =>
      _fallbackPollingTimer != null && _fallbackPollingTimer!.isActive;

  ActiveOrderCubit({
    required this.orderRepository,
    this.localeController,
  }) : super(const ActiveOrderIdle()) {
    if (localeController != null) {
      _localeListener = () => reloadActiveOrder();
      localeController!.addListener(_localeListener!);
    }
  }

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
      (failure) {
        if (state is ActiveOrderOfferReceived) {
          cancelOfferTimers();
          emit(const ActiveOrderIdle());
        }
      },
      (offer) {
        if (offer != null && offer.secondsLeft > 0) {
          // If we are already on this offer, sync smoothly without resetting initialSeconds
          if (state is ActiveOrderOfferReceived &&
              (state as ActiveOrderOfferReceived).offer.id == offer.id) {
            final curr = state as ActiveOrderOfferReceived;
            // Only adjust _remainingSeconds if drift from server is noticeable (> 2s) to prevent jitter
            if ((_remainingSeconds - offer.secondsLeft).abs() > 2) {
              _remainingSeconds = offer.secondsLeft;
            }
            emit(curr.copyWith(
              offer: offer,
              secondsRemaining: _remainingSeconds,
            ));
          } else {
            _remainingSeconds = offer.secondsLeft;
            emit(ActiveOrderOfferReceived(
              offer: offer,
              secondsRemaining: offer.secondsLeft,
              initialSeconds: offer.secondsLeft,
            ));
            _startOfferTimers(offer.secondsLeft);
          }
        } else {
          if (state is ActiveOrderOfferReceived) {
            cancelOfferTimers();
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
        cancelOfferTimers();
        // 404 or 422: offer no longer available
        emit(
          ActiveOrderActionError(
            message: failure.message,
            nextState: const ActiveOrderIdle(),
          ),
        );
      },
      (acceptedOrder) {
        cancelOfferTimers();
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

  /// Reloads active order details from the server when an order is in progress
  /// (e.g. status is 'assigned' or 'on_the_way', NOT a pending waiting offer).
  ///
  /// Typically called when the app language changes so that localized text
  /// (such as restaurant name and addresses) is returned in the newly selected language.
  Future<void> reloadActiveOrder() async {
    final curr = state;
    if (curr is ActiveOrderInProgress) {
      final orderId = curr.order.id;
      final res = await orderRepository.getOrderDetails(orderId);
      if (isClosed) return;
      await res.fold(
        (failure) async {
          // Fallback to getOrders(scope: 'current') if getOrderDetails fails
          final fallbackRes = await orderRepository.getOrders(
            scope: 'current',
            perPage: 5,
            page: 1,
          );
          if (isClosed) return;
          fallbackRes.fold(
            (_) {},
            (paginated) {
              if (paginated.items.isNotEmpty) {
                final first = paginated.items.first;
                if (first.status == 'assigned' || first.status == 'on_the_way') {
                  emit(ActiveOrderInProgress(order: first));
                }
              }
            },
          );
        },
        (order) async {
          if (order.status == 'delivered') {
            emit(const ActiveOrderIdle());
          } else if (order.status == 'assigned' || order.status == 'on_the_way') {
            emit(ActiveOrderInProgress(order: order));
          }
        },
      );
    }
  }

  void _startOfferTimers(int secondsLeft) {
    cancelOfferTimers();
    _remainingSeconds = secondsLeft;

    // 1-second countdown timer: decrements remaining seconds and updates state
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        cancelOfferTimers();
        emit(const ActiveOrderIdle());
      } else {
        final curr = state;
        if (curr is ActiveOrderOfferReceived) {
          emit(curr.copyWith(secondsRemaining: _remainingSeconds));
        }
      }
    });

    // 5-second polling timer per Section 3 requirement
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Avoid polling while user is actively accepting the offer
      if (state is ActiveOrderOfferReceived &&
          (state as ActiveOrderOfferReceived).isAccepting) {
        return;
      }

      final res = await orderRepository.getCurrentOffer();
      res.fold(
        (failure) {
          if (failure is NotFoundFailure || failure.statusCode == 404) {
            cancelOfferTimers();
            emit(const ActiveOrderIdle());
          }
        },
        (offer) {
          if (offer == null) {
            // Offer expired or taken by another driver -> cancel timers and close screen immediately
            cancelOfferTimers();
            emit(const ActiveOrderIdle());
          } else {
            // Keep remaining seconds in sync if server seconds_left is lower
            if (offer.secondsLeft < _remainingSeconds || _remainingSeconds <= 0) {
              _remainingSeconds = offer.secondsLeft;
            }
            final curr = state;
            if (curr is ActiveOrderOfferReceived) {
              emit(curr.copyWith(
                offer: offer,
                secondsRemaining: _remainingSeconds,
              ));
            }
          }
        },
      );
    });
  }

  /// Starts lightweight fallback polling (every 15-30s, default 20s) when app is in foreground and driver is online
  void startFallbackPolling({
    Duration interval = const Duration(seconds: 20),
    bool Function()? isOnline,
  }) {
    stopFallbackPolling();
    _fallbackPollingTimer = Timer.periodic(interval, (_) async {
      if (isOnline != null && !isOnline()) {
        return;
      }
      // Only poll for an offer if currently idle (no active order or offer)
      if (state is ActiveOrderIdle) {
        await checkCurrentOffer();
      }
    });
  }

  void stopFallbackPolling() {
    _fallbackPollingTimer?.cancel();
    _fallbackPollingTimer = null;
  }

  void cancelOfferTimers() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds = 0;
  }

  void cancelTimers() {
    cancelOfferTimers();
    stopFallbackPolling();
  }

  @override
  Future<void> close() {
    if (_localeListener != null && localeController != null) {
      localeController!.removeListener(_localeListener!);
      _localeListener = null;
    }
    cancelTimers();
    return super.close();
  }
}
