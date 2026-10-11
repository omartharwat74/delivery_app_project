extension PhoneFormatterExt on String {
  String formatAsEgyptianPhone() {
    String digits = replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isNotEmpty && !digits.startsWith('0')) {
      digits = '0$digits';
    }
    return digits;
  }
}
