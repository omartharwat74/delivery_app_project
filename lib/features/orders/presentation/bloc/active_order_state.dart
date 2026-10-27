import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

abstract class ActiveOrderState extends Equatable {
  const ActiveOrderState();

  @override
  List<Object?> get props => [];
}

/// Initial / idle state when there is no active offer and no active order.
class ActiveOrderIdle extends ActiveOrderState {
  const ActiveOrderIdle();
}

/// Loading state (e.g. during state restoration on startup).
class ActiveOrderLoading extends ActiveOrderState {
  const ActiveOrderLoading();
}

/// Stage 1: New order offer received waiting for driver's decision.
class ActiveOrderOfferReceived extends ActiveOrderState {
  final OrderOfferEntity offer;
  final bool isAccepting;

  const ActiveOrderOfferReceived({
    required this.offer,
    this.isAccepting = false,
  });

  ActiveOrderOfferReceived copyWith({
    OrderOfferEntity? offer,
    bool? isAccepting,
  }) {
    return ActiveOrderOfferReceived(
      offer: offer ?? this.offer,
      isAccepting: isAccepting ?? this.isAccepting,
    );
  }

  @override
  List<Object?> get props => [offer, isAccepting];
}

/// Stages 2 & 3: Order accepted and currently in progress.
/// Stage 2: assigned (pickup pending).
/// Stage 3: on_the_way (delivery pending).
class ActiveOrderInProgress extends ActiveOrderState {
  final OrderEntity order;
  final bool isUpdatingStatus;

  const ActiveOrderInProgress({
    required this.order,
    this.isUpdatingStatus = false,
  });

  bool get isAssigned => order.status == 'assigned';
  bool get isOnTheWay => order.status == 'on_the_way';

  ActiveOrderInProgress copyWith({
    OrderEntity? order,
    bool? isUpdatingStatus,
  }) {
    return ActiveOrderInProgress(
      order: order ?? this.order,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    );
  }

  @override
  List<Object?> get props => [order, isUpdatingStatus];
}

/// Transient error state for action failures (404, 422, etc.).
class ActiveOrderActionError extends ActiveOrderState {
  final String message;
  final ActiveOrderState nextState;

  const ActiveOrderActionError({
    required this.message,
    required this.nextState,
  });

  @override
  List<Object?> get props => [message, nextState];
}
