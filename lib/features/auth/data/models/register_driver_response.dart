class RegisterDriverResponse {
  final String status;
  final String message;

  const RegisterDriverResponse({
    required this.status,
    required this.message,
  });

  bool get isPendingReview => status == 'pending_review';

  factory RegisterDriverResponse.fromJson(Map<String, dynamic> json) {
    return RegisterDriverResponse(
      status: json['status'] as String? ?? 'pending_review',
      message: json['message'] as String? ??
          'تم إرسال طلبك وهو قيد مراجعة الإدارة.',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}
