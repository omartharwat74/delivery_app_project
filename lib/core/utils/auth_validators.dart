import 'english_digits_formatter.dart';

class AuthValidators {
  AuthValidators._();

  static String? emailBasic(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return requiredMessage;
    final basic = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!basic.hasMatch(email)) return invalidMessage;
    return null;
  }

  static String? usernameRegister(
    String? value, {
    required String requiredMessage,
    required String minMessage,
  }) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return requiredMessage;
    if (name.length < 3) return minMessage;
    return null;
  }

  static String? egyptianPhone(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    var digits = EnglishDigitsOnlyFormatter.toEnglishDigits(value ?? '');
    if (digits.isEmpty) return requiredMessage;
    if (digits.startsWith('20') && digits.length >= 12) {
      digits = digits.substring(2);
    }
    if (digits.length == 11 && digits.startsWith('01')) return null;
    if (digits.length == 10 && digits.startsWith('1')) return null;
    return invalidMessage;
  }

  static String? egyptianNationalId(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final digits = EnglishDigitsOnlyFormatter.toEnglishDigits(value ?? '');
    if (digits.isEmpty) return requiredMessage;
    if (digits.length != 14) return invalidMessage;
    return null;
  }

  static String? requiredText(
    String? value, {
    required String requiredMessage,
  }) {
    if ((value ?? '').trim().isEmpty) return requiredMessage;
    return null;
  }

  static String? requiredSelection(
    String? value, {
    required String requiredMessage,
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return null;
  }

  static String? requiredUpload(
    String? fileName, {
    required String requiredMessage,
  }) {
    if (fileName == null || fileName.trim().isEmpty) return requiredMessage;
    return null;
  }

  static String? requiredImageFile(
    Object? file, {
    required String requiredMessage,
  }) {
    if (file == null) return requiredMessage;
    return null;
  }

  static String? requiredProfilePhoto(
    bool hasPhoto, {
    required String requiredMessage,
  }) {
    if (!hasPhoto) return requiredMessage;
    return null;
  }

  static String? otpSixDigits(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final s = EnglishDigitsOnlyFormatter.toEnglishDigits(value ?? '');
    if (s.isEmpty) return requiredMessage;
    if (s.length != 6) return invalidMessage;
    return null;
  }
}
