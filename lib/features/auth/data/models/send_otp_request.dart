class SendOtpRequest {
  final String phone;

  const SendOtpRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}
