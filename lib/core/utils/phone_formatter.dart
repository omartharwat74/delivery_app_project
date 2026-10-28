import 'english_digits_formatter.dart';

extension PhoneFormatterExt on String {
  String formatAsEgyptianPhone() {
    String digits = EnglishDigitsOnlyFormatter.toEnglishDigits(this);
    if (digits.isNotEmpty && !digits.startsWith('0')) {
      digits = '0$digits';
    }
    return digits;
  }
}

