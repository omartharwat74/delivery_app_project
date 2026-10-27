import 'package:equatable/equatable.dart';

class OrderStoreEntity extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? logo;
  final String? deliveryMode;
  final double? lat;
  final double? long;

  const OrderStoreEntity({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.logo,
    this.deliveryMode,
    this.lat,
    this.long,
  });

  @override
  List<Object?> get props => [id, name, phone, address, logo, deliveryMode, lat, long];
}

class OrderCustomerEntity extends Equatable {
  final int? id;
  final String name;
  final String phone;

  const OrderCustomerEntity({
    this.id,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, phone];
}

class OrderItemEntity extends Equatable {
  final int? productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String? image;

  const OrderItemEntity({
    this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.image,
  });

  @override
  List<Object?> get props => [productId, name, quantity, unitPrice, lineTotal, image];
}

class OrderSummaryEntity extends Equatable {
  final double itemsTotal;
  final double tax;
  final double delivery;
  final double total;

  const OrderSummaryEntity({
    this.itemsTotal = 0.0,
    this.tax = 0.0,
    this.delivery = 0.0,
    required this.total,
  });

  @override
  List<Object?> get props => [itemsTotal, tax, delivery, total];
}

class OrderAddressEntity extends Equatable {
  final int? id;
  final String? name;
  final String fullAddress;
  final double? lat;
  final double? long;

  const OrderAddressEntity({
    this.id,
    this.name,
    required this.fullAddress,
    this.lat,
    this.long,
  });

  @override
  List<Object?> get props => [id, name, fullAddress, lat, long];
}

class OrderEntity extends Equatable {
  final int id;
  final String code;
  final String status;
  final String? paymentMethod;
  final bool? selfPickup;
  final String? deliveryMode;
  final OrderStoreEntity? store;
  final OrderCustomerEntity? customer;
  final List<OrderItemEntity> items;
  final OrderSummaryEntity? summary;
  final double? earning;
  final OrderAddressEntity? address;
  final DateTime? createdAt;
  final String? cancelReason;

  // Static placeholders for attributes not currently calculated in backend
  // TODO(API): static for now
  final String? estimatedDistance;
  // TODO(API): static for now
  final String? estimatedTime;

  const OrderEntity({
    required this.id,
    required this.code,
    required this.status,
    this.paymentMethod,
    this.selfPickup,
    this.deliveryMode,
    this.store,
    this.customer,
    this.items = const [],
    this.summary,
    this.earning,
    this.address,
    this.createdAt,
    this.cancelReason,
    this.estimatedDistance,
    this.estimatedTime,
  });

  // Convenience getters for UI compatibility
  String get restaurantName => store?.name ?? '';
  String get pickupAddress => store?.address ?? store?.name ?? '';
  String get deliveryAddress => address?.fullAddress ?? '';
  String get customerName => customer?.name ?? '';
  String get customerPhone => customer?.phone ?? '';
  double get deliveryFee => earning ?? summary?.delivery ?? 0.0;
  double get totalPrice => summary?.total ?? 0.0;
  int get totalItems => items.isNotEmpty
      ? items.fold<int>(0, (sum, i) => sum + i.quantity)
      : 0;

  bool get isAssigned => status == 'assigned';
  bool get isOnTheWay => status == 'on_the_way';
  bool get isDelivered => status == 'delivered';

  /// 3-segment progress: assigned = 1, on_the_way = 2, delivered = 3
  int get progressSegments {
    if (isDelivered) return 3;
    if (isOnTheWay) return 2;
    return 1;
  }

  @override
  List<Object?> get props => [
        id,
        code,
        status,
        paymentMethod,
        selfPickup,
        deliveryMode,
        store,
        customer,
        items,
        summary,
        earning,
        address,
        createdAt,
        cancelReason,
        estimatedDistance,
        estimatedTime,
      ];
}

class OrderOfferEntity extends Equatable {
  final int id;
  final DateTime? expiresAt;
  final int secondsLeft;
  final OrderEntity order;

  const OrderOfferEntity({
    required this.id,
    this.expiresAt,
    required this.secondsLeft,
    required this.order,
  });

  @override
  List<Object?> get props => [id, expiresAt, secondsLeft, order];
}
