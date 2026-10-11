import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/driver_model.dart';

abstract class SettingsRemoteDataSource {
  /// Toggle driver push notifications (PUT /profile/notifications)
  Future<DriverModel> updateNotifications({required bool isNotify});

  /// Send verification code to current phone number (POST /profile/phone/send-current-otp)
  Future<Map<String, dynamic>> sendCurrentOtp();

  /// Verify current phone number OTP (POST /profile/phone/verify-current-otp)
  /// Returns phone_change_token
  Future<String> verifyCurrentOtp({required String otp});

  /// Send verification code to new phone number (POST /profile/phone/send-otp)
  Future<Map<String, dynamic>> sendNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
  });

  /// Verify new phone number OTP and update phone (POST /profile/phone/verify-otp)
  /// Returns updated DriverModel
  Future<DriverModel> verifyNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
    required String otp,
  });
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient apiClient;

  SettingsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DriverModel> updateNotifications({required bool isNotify}) async {
    final response = await apiClient.putResponse<DriverModel>(
      ApiConstants.profileNotifications,
      body: {'is_notify': isNotify},
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return DriverModel.fromJson(data);
        }
        throw Exception('Invalid driver data format');
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg.isNotEmpty ? response.msg : 'Failed to update notifications');
  }

  @override
  Future<Map<String, dynamic>> sendCurrentOtp() async {
    final response = await apiClient.postResponse<Map<String, dynamic>>(
      ApiConstants.sendCurrentOtp,
      body: {},
      fromJson: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<String> verifyCurrentOtp({required String otp}) async {
    final response = await apiClient.postResponse<Map<String, dynamic>>(
      ApiConstants.verifyCurrentOtp,
      body: {'otp': otp},
      fromJson: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
    );

    final data = response.data;
    final token = data?['phone_change_token'] as String?;
    if (token != null && token.isNotEmpty) {
      return token;
    }
    throw Exception(
      response.msg.isNotEmpty
          ? response.msg
          : 'phone_change_token not found in response',
    );
  }

  @override
  Future<Map<String, dynamic>> sendNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
  }) async {
    final response = await apiClient.postResponse<Map<String, dynamic>>(
      ApiConstants.profileSendOtp,
      body: {
        'phone_change_token': phoneChangeToken,
        'phone': newPhone,
      },
      fromJson: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
    );

    return response.data ?? <String, dynamic>{};
  }

  @override
  Future<DriverModel> verifyNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
    required String otp,
  }) async {
    final response = await apiClient.postResponse<DriverModel>(
      ApiConstants.profileVerifyOtp,
      body: {
        'phone_change_token': phoneChangeToken,
        'phone': newPhone,
        'otp': otp,
      },
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return DriverModel.fromJson(data);
        }
        throw Exception('Invalid driver data format');
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw Exception(
      response.msg.isNotEmpty ? response.msg : 'Failed to verify new phone OTP',
    );
  }
}
