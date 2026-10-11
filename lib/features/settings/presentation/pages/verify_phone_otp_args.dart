class VerifyPhoneOtpArgs {
  final String phoneNumber;
  final bool isCurrentPhone;
  final String? newPhoneNumber;

  const VerifyPhoneOtpArgs({
    required this.phoneNumber,
    this.isCurrentPhone = false,
    this.newPhoneNumber,
  });
}
