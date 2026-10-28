import '../../domain/entities/order_entity.dart';

double _asDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _asInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class OrderStoreModel extends OrderStoreEntity {
  const OrderStoreModel({
    super.id,
    required super.name,
    super.phone,
    super.address,
    super.logo,
    super.deliveryMode,
    super.lat,
    super.long,
  });

  factory OrderStoreModel.fromJson(Map<String, dynamic> json) {
    // TODO(API): store lat/lng not returned by backend yet
    return OrderStoreModel(
      id: json['id'] != null ? _asInt(json['id']) : null,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      logo: json['logo']?.toString(),
      deliveryMode: json['delivery_mode']?.toString(),
      lat: (json['lat'] ?? json['latitude'] ?? json['store_lat']) != null
          ? _asDouble(json['lat'] ?? json['latitude'] ?? json['store_lat'])
          : null,
      long: (json['long'] ?? json['lng'] ?? json['longitude'] ?? json['store_lng']) != null
          ? _asDouble(json['long'] ?? json['lng'] ?? json['longitude'] ?? json['store_lng'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'logo': logo,
        'delivery_mode': deliveryMode,
        'lat': lat,
        'long': long,
      };
}

class OrderCustomerModel extends OrderCustomerEntity {
  const OrderCustomerModel({
    super.id,
    required super.name,
    required super.phone,
  });

  factory OrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerModel(
      id: json['id'] != null ? _asInt(json['id']) : null,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
      };
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    super.productId,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    required super.lineTotal,
    super.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] != null ? _asInt(json['product_id']) : null,
      name: json['name']?.toString() ?? '',
      quantity: _asInt(json['quantity'], 1),
      unitPrice: _asDouble(json['unit_price']),
      lineTotal: _asDouble(json['line_total']),
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        'line_total': lineTotal,
        'image': image,
      };
}

class OrderSummaryModel extends OrderSummaryEntity {
  const OrderSummaryModel({
    super.itemsTotal,
    super.tax,
    super.delivery,
    required super.total,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      itemsTotal: _asDouble(json['items_total'] ?? json['items_subtotal']),
      tax: _asDouble(json['tax']),
      delivery: _asDouble(json['delivery']),
      total: _asDouble(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'items_total': itemsTotal,
        'tax': tax,
        'delivery': delivery,
        'total': total,
      };
}

class OrderAddressModel extends OrderAddressEntity {
  const OrderAddressModel({
    super.id,
    super.name,
    required super.fullAddress,
    super.lat,
    super.long,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
      id: json['id'] != null ? _asInt(json['id']) : null,
      name: json['name']?.toString(),
      fullAddress: json['full_address']?.toString() ?? json['address']?.toString() ?? '',
      lat: json['lat'] != null ? _asDouble(json['lat']) : null,
      long: json['long'] != null ? _asDouble(json['long']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'full_address': fullAddress,
        'lat': lat,
        'long': long,
      };
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.code,
    required super.status,
    super.paymentMethod,
    super.selfPickup,
    super.deliveryMode,
    super.store,
    super.customer,
    super.items,
    super.summary,
    super.earning,
    super.address,
    super.createdAt,
    super.cancelReason,
    super.estimatedDistance,
    super.estimatedTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse items list safely
    List<OrderItemModel> itemsList = [];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    return OrderModel(
      id: _asInt(json['id']),
      code: json['code']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString(),
      selfPickup: json['self_pickup'] as bool?,
      deliveryMode: json['delivery_mode']?.toString(),
      store: json['store'] is Map<String, dynamic>
          ? OrderStoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? OrderCustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      items: itemsList,
      summary: json['summary'] is Map<String, dynamic>
          ? OrderSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      earning: json['earning'] != null ? _asDouble(json['earning']) : null,
      address: json['address'] is Map<String, dynamic>
          ? OrderAddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      cancelReason: json['cancel_reason']?.toString(),
      // TODO(API): static for now
      estimatedDistance: '2.5',
      // TODO(API): static for now
      estimatedTime: '20 : 15 دقيقة',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'status': status,
        'payment_method': paymentMethod,
        'self_pickup': selfPickup,
        'delivery_mode': deliveryMode,
        'store': (store as OrderStoreModel?)?.toJson(),
        'customer': (customer as OrderCustomerModel?)?.toJson(),
        'items': items.map((i) => (i as OrderItemModel).toJson()).toList(),
        'summary': (summary as OrderSummaryModel?)?.toJson(),
        'earning': earning,
        'address': (address as OrderAddressModel?)?.toJson(),
        'created_at': createdAt?.toIso8601String(),
        'cancel_reason': cancelReason,
      };
}

class OrderOfferModel extends OrderOfferEntity {
  const OrderOfferModel({
    required super.id,
    super.expiresAt,
    required super.secondsLeft,
    required super.order,
  });

  factory OrderOfferModel.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order'] as Map<String, dynamic>? ?? {};
    return OrderOfferModel(
      id: _asInt(json['id']),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      secondsLeft: _asInt(json['seconds_left'], 60),
      order: OrderModel.fromJson(orderJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'expires_at': expiresAt?.toIso8601String(),
        'seconds_left': secondsLeft,
        'order': (order as OrderModel).toJson(),
      };
}

class OrdersPaginatedResponse {
  final List<OrderModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const OrdersPaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory OrdersPaginatedResponse.fromJson(Map<String, dynamic> json) {
    List<OrderModel> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((x) => OrderModel.fromJson(x))
          .toList();
    }

    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return OrdersPaginatedResponse(
      items: items,
      currentPage: _asInt(meta['current_page'], 1),
      lastPage: _asInt(meta['last_page'], 1),
      perPage: _asInt(meta['per_page'], 10),
      total: _asInt(meta['total'], items.length),
    );
  }
}
