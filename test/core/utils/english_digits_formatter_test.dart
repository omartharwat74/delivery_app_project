import 'package:delivery_app_project/core/utils/english_digits_formatter.dart';
import 'package:delivery_app_project/core/utils/phone_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnglishDigitsOnlyFormatter', () {
    test('toEnglishDigits converts Eastern Arabic numerals to English digits', () {
      expect(
        EnglishDigitsOnlyFormatter.toEnglishDigits('٠١٢٣٤٥٦٧٨٩'),
        '0123456789',
      );
    });

    test('toEnglishDigits converts Persian numerals to English digits', () {
      expect(
        EnglishDigitsOnlyFormatter.toEnglishDigits('۰۱۲۳۴۵۶۷۸۹'),
        '0123456789',
      );
    });

    test('toEnglishDigits strips non-digit characters and symbols', () {
      expect(
        EnglishDigitsOnlyFormatter.toEnglishDigits('٠١٠-١٢٣٤ ٥٦٧٨!'),
        '01012345678',
      );
      expect(
        EnglishDigitsOnlyFormatter.toEnglishDigits('+20 100 123 4567 (EG)'),
        '201001234567',
      );
    });

    test('toEnglishDigits handles empty string', () {
      expect(EnglishDigitsOnlyFormatter.toEnglishDigits(''), '');
    });

    test('formatEditUpdate converts input and respects maxLength', () {
      const formatter = EnglishDigitsOnlyFormatter(maxLength: 11);
      final oldValue = const TextEditingValue(text: '');
      final newValue = const TextEditingValue(
        text: '٠١٠١٢٣٤٥٦٧٨٩٩٩', // 14 digits in Arabic
        selection: TextSelection.collapsed(offset: 14),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '01012345678');
      expect(result.text.length, 11);
      expect(result.selection.end, 11);
    });

    test('formatEditUpdate handles cursor offset correctly within bounds', () {
      const formatter = EnglishDigitsOnlyFormatter(maxLength: 6);
      final oldValue = const TextEditingValue(text: '12');
      final newValue = const TextEditingValue(
        text: '12٣4',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1234');
      expect(result.selection.end, 4);
    });

    test('formatEditUpdate handles otp max length 6', () {
      const formatter = EnglishDigitsOnlyFormatter(maxLength: 6);
      final oldValue = const TextEditingValue(text: '');
      final newValue = const TextEditingValue(
        text: '١٢٣٤٥٦',
        selection: TextSelection.collapsed(offset: 6),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '123456');
    });
  });

  group('PhoneFormatterExt with EnglishDigitsOnlyFormatter', () {
    test('formatAsEgyptianPhone converts Arabic digits and ensures leading zero', () {
      expect('١٠١٢٣٤٥٦٧٨'.formatAsEgyptianPhone(), '01012345678');
      expect('٠١٠١٢٣٤٥٦٧٨'.formatAsEgyptianPhone(), '01012345678');
      expect('01012345678'.formatAsEgyptianPhone(), '01012345678');
    });
  });
}
