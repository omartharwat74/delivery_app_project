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
    double? lat,
    double? lng,
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
    // Uses real GPS coordinates when available; falls back to default test location if 0.0
    final effectiveLat = lat != 0.0 ? lat : 30.095;
    final effectiveLng = lng != 0.0 ? lng : 31.63;

    return client.patchResponse<Map<String, dynamic>>(
      ApiConstants.location,
      body: {
        'lat': effectiveLat,
        'lng': effectiveLng,
      },
      fromJson: (data) =>
          data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateAvailability({
    required bool isOnline,
    double? lat,
    double? lng,
  }) {
    // Uses real GPS coordinates when available; falls back to default test location if null or 0.0
    final effectiveLat = (lat != null && lat != 0.0) ? lat : 30.095;
    final effectiveLng = (lng != null && lng != 0.0) ? lng : 31.63;

    return client.patchResponse<Map<String, dynamic>>(
      ApiConstants.availability,
      body: {
        'is_online': isOnline,
        'lat': effectiveLat,
        'lng': effectiveLng,
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
