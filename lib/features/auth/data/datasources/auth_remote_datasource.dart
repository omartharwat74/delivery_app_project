import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/driver_model.dart';
import '../models/logout_request.dart';
import '../models/register_driver_request.dart';
import '../models/register_driver_response.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../models/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<SendOtpResponse>> sendOtp(SendOtpRequest request);
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(VerifyOtpRequest request);
  Future<ApiResponse<RegisterDriverResponse>> registerDriver(
    RegisterDriverRequest request,
  );
  Future<ApiResponse<void>> logout(LogoutRequest request);
  Future<ApiResponse<DriverModel>> getMe();

  // Legacy methods for backwards compatibility
  Future<Map<String, dynamic>> sendDriverLoginOtp(String phone);
  Future<Map<String, dynamic>> verifyDriverLoginOtp(String phone, String otp);
  Future<Map<String, dynamic>> uploadMedia(String filePath);
  Future<AuthResponse> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ApiResponse<SendOtpResponse>> sendOtp(SendOtpRequest request) async {
    return apiClient.postResponse<SendOtpResponse>(
      ApiConstants.sendOtp,
      body: request.toJson(),
      fromJson: (data) =>
          SendOtpResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(
    VerifyOtpRequest request,
  ) async {
    return apiClient.postResponse<VerifyOtpResponse>(
      ApiConstants.verifyOtp,
      body: request.toJson(),
      fromJson: (data) =>
          VerifyOtpResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RegisterDriverResponse>> registerDriver(
    RegisterDriverRequest request,
  ) async {
    final formData = await request.toFormData();
    return apiClient.postResponse<RegisterDriverResponse>(
      ApiConstants.register,
      body: formData,
      fromJson: (data) =>
          RegisterDriverResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> logout(LogoutRequest request) async {
    return apiClient.postResponse<void>(
      ApiConstants.logout,
      body: request.toJson(),
    );
  }

  @override
  Future<ApiResponse<DriverModel>> getMe() async {
    return apiClient.getResponse<DriverModel>(
      ApiConstants.me,
      fromJson: (data) {
        final map = data as Map<String, dynamic>;
        // In GET /auth/me, the driver is nested under data.delivery
        final deliveryMap = map['delivery'] is Map<String, dynamic>
            ? map['delivery'] as Map<String, dynamic>
            : map;
        return DriverModel.fromJson(deliveryMap);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Legacy wrappers for backwards compatibility
  // ---------------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> sendDriverLoginOtp(String phone) async {
    final res = await sendOtp(SendOtpRequest(phone: phone));
    return {'status': res.status, 'msg': res.msg, 'data': res.data?.toJson()};
  }

  @override
  Future<Map<String, dynamic>> verifyDriverLoginOtp(
    String phone,
    String otp,
  ) async {
    final res = await verifyOtp(
      VerifyOtpRequest(
        phone: phone,
        otp: otp,
        deviceId: 'legacy-device',
      ),
    );
    return {'status': res.status, 'msg': res.msg, 'data': res.data?.toJson()};
  }

  @override
  Future<Map<String, dynamic>> uploadMedia(String filePath) async {
    return apiClient.postMultipartFile(
      ApiConstants.uploadMedia,
      filePath: filePath,
      fieldName: 'file',
    );
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    return const AuthResponse(
      accessToken: '',
      refreshToken: '',
      tokenType: 'Bearer',
      userId: '',
      phone: '',
      firstName: '',
      lastName: '',
      fullName: '',
      role: 'driver',
      newUser: false,
    );
  }
}
