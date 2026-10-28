import 'package:flutter/services.dart';

/// Formatter that strictly enforces standard English digits (0-9).
/// It converts any Eastern Arabic (٠-٩) or Persian (۰-۹) numerals into
/// standard English digits in real-time, strips non-digit characters,
/// and optionally limits maximum length.
class EnglishDigitsOnlyFormatter extends TextInputFormatter {
  final int? maxLength;

  const EnglishDigitsOnlyFormatter({this.maxLength});

  /// Converts all Eastern Arabic and Persian numerals to Western Arabic/English digits (0-9),
  /// and strips any non-digit characters.
  static String toEnglishDigits(String input) {
    if (input.isEmpty) return input;
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], english[i]);
      result = result.replaceAll(persian[i], english[i]);
    }
    return result.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String converted = toEnglishDigits(newValue.text);
    if (maxLength != null && converted.length > maxLength!) {
      converted = converted.substring(0, maxLength!);
    }

    final textBeforeCursor = newValue.text.substring(
      0,
      newValue.selection.end.clamp(0, newValue.text.length),
    );
    final convertedBeforeCursor = toEnglishDigits(textBeforeCursor);
    int newOffset = convertedBeforeCursor.length;
    if (maxLength != null && newOffset > maxLength!) {
      newOffset = maxLength!;
    }

    return TextEditingValue(
      text: converted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
