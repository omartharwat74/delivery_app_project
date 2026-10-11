import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.getResponse<List<NotificationModel>>(
      ApiConstants.notifications,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList();
        }
        return <NotificationModel>[];
      },
    );

    return response.data ?? <NotificationModel>[];
  }
}
