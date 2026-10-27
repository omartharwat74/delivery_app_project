import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  /// GET /orders/offer
  Future<OrderOfferModel?> getCurrentOffer();

  /// POST /orders/offers/{offerId}/accept
  Future<OrderModel> acceptOffer(int offerId);

  /// POST /orders/offers/{offerId}/reject
  Future<void> rejectOffer(int offerId);

  /// PATCH /orders/{orderId}/status
  Future<OrderModel> updateOrderStatus(int orderId, String status);

  /// GET /orders?scope={current|past}&per_page={5,10,20...}&page={page}
  Future<OrdersPaginatedResponse> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  });

  /// GET /orders/{orderId}
  Future<OrderModel> getOrderDetails(int orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl(this.apiClient);

  @override
  Future<OrderOfferModel?> getCurrentOffer() async {
    final response = await apiClient.getResponse<OrderOfferModel?>(
      ApiConstants.orderOffer,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          final offerData = data['offer'];
          if (offerData is Map<String, dynamic>) {
            return OrderOfferModel.fromJson(offerData);
          }
        }
        return null;
      },
    );
    return response.data;
  }

  @override
  Future<OrderModel> acceptOffer(int offerId) async {
    final response = await apiClient.postResponse<OrderModel>(
      ApiConstants.acceptOffer(offerId),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        throw Exception('Invalid order payload');
      },
    );
    if (response.data != null) {
      return response.data!;
    }
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to accept offer',
    );
  }

  @override
  Future<void> rejectOffer(int offerId) async {
    await apiClient.postResponse<void>(
      ApiConstants.rejectOffer(offerId),
    );
  }

  @override
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final response = await apiClient.patchResponse<OrderModel>(
      ApiConstants.orderStatus(orderId),
      body: {'status': status},
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        throw Exception('Invalid order status update payload');
      },
    );
    if (response.data != null) {
      return response.data!;
    }
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to update order status',
    );
  }

  @override
  Future<OrdersPaginatedResponse> getOrders({
    String? scope,
    int perPage = 10,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (scope != null && scope.isNotEmpty) {
      queryParams['scope'] = scope;
    }

    final response = await apiClient.getResponse<OrdersPaginatedResponse>(
      ApiConstants.ordersList,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return OrdersPaginatedResponse.fromJson(data);
        }
        return const OrdersPaginatedResponse(
          items: [],
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 0,
        );
      },
    );
    return response.data ??
        const OrdersPaginatedResponse(
          items: [],
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 0,
        );
  }

  @override
  Future<OrderModel> getOrderDetails(int orderId) async {
    final response = await apiClient.getResponse<OrderModel>(
      ApiConstants.orderDetails(orderId),
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        throw Exception('Invalid order details payload');
      },
    );
    if (response.data != null) {
      return response.data!;
    }
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to load order details',
    );
  }
}
