class VerifyOtpRequest {
  final String phone;
  final String otp;
  final String deviceId;
  final String? platform;
  final String? deviceName;
  final String? appVersion;

  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
    required this.deviceId,
    this.platform,
    this.deviceName,
    this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
        'device_id': deviceId,
        if (platform != null) 'platform': platform,
        if (deviceName != null) 'device_name': deviceName,
        if (appVersion != null) 'app_version': appVersion,
      };
}
