class LogoutRequest {
  final String deviceId;

  const LogoutRequest({required this.deviceId});

  Map<String, dynamic> toJson() => {'device_id': deviceId};
}
