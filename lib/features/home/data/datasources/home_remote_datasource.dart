import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

abstract class HomeRemoteDataSource {
  /// PATCH /auth/update-fcm
  Future<ApiResponse<void>> updateFcmToken({
    required String deviceId,
    required String fcmToken,
    String? platform,
  });

  /// PATCH /auth/location
  Future<ApiResponse<Map<String, dynamic>>> updateLocation({
    required double lat,
    required double lng,
  });

  /// PATCH /attendance/availability (Attendance punch clock)
  Future<ApiResponse<Map<String, dynamic>>> updateAvailability({
    required bool isOnline,
  });

  Future<Map<String, dynamic>> getTodayStats();
  Future<Map<String, dynamic>> toggleOnlineStatus(bool isOnline);
  Future<List<dynamic>> getShifts();
  Future<Map<String, dynamic>> bookShift(Map<String, dynamic> body);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient client;
  HomeRemoteDataSourceImpl(this.client);

  @override
  Future<ApiResponse<void>> updateFcmToken({
    required String deviceId,
    required String fcmToken,
    String? platform,
  }) {
    return client.patchResponse<void>(
      ApiConstants.updateFcm,
      body: {
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'platform': ?platform,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateLocation({
    required double lat,
    required double lng,
  }) {
    return client.patchResponse<Map<String, dynamic>>(
      ApiConstants.location,
      body: {
        'lat': lat,
        'lng': lng,
      },
      fromJson: (data) =>
          data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateAvailability({
    required bool isOnline,
  }) {
    return client.patchResponse<Map<String, dynamic>>(
      ApiConstants.availability,
      body: {
        'is_online': isOnline,
      },
      fromJson: (data) =>
          data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<Map<String, dynamic>> getTodayStats() =>
      client.get(ApiConstants.todayStats);

  @override
  Future<Map<String, dynamic>> toggleOnlineStatus(bool isOnline) =>
      client.post(ApiConstants.driverStatus, body: {'is_online': isOnline});

  @override
  Future<List<dynamic>> getShifts() async {
    final res = await client.get(ApiConstants.shifts);
    return res['data'] as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> bookShift(Map<String, dynamic> body) =>
      client.post(ApiConstants.shifts, body: body);
}
