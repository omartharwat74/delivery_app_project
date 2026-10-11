import 'driver_model.dart';

class VerifyOtpResponse {
  final String status;
  final String? token;
  final String? registrationToken;
  final DriverModel? delivery;

  const VerifyOtpResponse({
    required this.status,
    this.token,
    this.registrationToken,
    this.delivery,
  });

  bool get isAuthenticated => status == 'authenticated';
  bool get isCompleteRegistration => status == 'complete_registration';

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status'] as String? ?? '',
      token: json['token'] as String?,
      registrationToken: json['registration_token'] as String?,
      delivery: json['delivery'] != null && json['delivery'] is Map<String, dynamic>
          ? DriverModel.fromJson(json['delivery'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        if (token != null) 'token': token,
        if (registrationToken != null) 'registration_token': registrationToken,
        if (delivery != null) 'delivery': delivery!.toJson(),
      };
}
