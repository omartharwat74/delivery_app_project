class SendOtpResponse {
  final String status;
  final String? debugOtp;

  const SendOtpResponse({
    required this.status,
    this.debugOtp,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status'] as String? ?? 'otp_sent',
      debugOtp: json['debug_otp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        if (debugOtp != null) 'debug_otp': debugOtp,
      };
}
