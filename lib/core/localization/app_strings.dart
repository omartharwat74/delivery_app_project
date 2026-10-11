import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection_container.dart';

/// Centralized bilingual string helper for network exceptions, client-side fallbacks,
/// and system messages that adapt dynamically to the app's current locale (Arabic / English).
class AppStrings {
  static bool get isEnglish {
    try {
      if (sl.isRegistered<SharedPreferences>()) {
        final prefs = sl<SharedPreferences>();
        return prefs.getString('driver_app_locale') == 'en';
      }
    } catch (_) {}
    return false;
  }

  // ---------------------------------------------------------------------------
  // Network & Error Messages
  // ---------------------------------------------------------------------------

  static String get connectionError => isEnglish
      ? 'Unable to connect to server. Please check your internet connection'
      : 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت';

  static String get unauthorized => isEnglish
      ? 'Unauthorized. Please log in'
      : 'غير مصرح. يرجى تسجيل الدخول';

  static String get forbidden => isEnglish
      ? 'Account has been blocked'
      : 'تم حظر الحساب';

  static String get notFound => isEnglish
      ? 'Requested resource not found'
      : 'العنصر غير موجود';

  static String serverErrorWithCode(int? code) {
    if (isEnglish) {
      return 'A server error occurred${code != null ? ' ($code)' : ''}';
    }
    return 'حدث خطأ في الخادم${code != null ? ' ($code)' : ''}';
  }

  static String get unexpectedError => isEnglish
      ? 'An unexpected error occurred'
      : 'حدث خطأ غير متوقع';

  // ---------------------------------------------------------------------------
  // Auth Flow Messages
  // ---------------------------------------------------------------------------

  static String get phoneRequired => isEnglish
      ? 'Phone number is missing. Please try again'
      : 'رقم الهاتف غير موجود. يرجى المحاولة مجدداً';

  static String get attachAllDocuments => isEnglish
      ? 'Please attach all required document photos'
      : 'يرجى إرفاق جميع صور المستندات المطلوبة';

  static String get pendingReview => isEnglish
      ? 'Your request has been submitted and is awaiting administration review.'
      : 'تم إرسال طلبك وهو قيد مراجعة الإدارة.';

  static String get unknownState => isEnglish
      ? 'Unknown state returned from server'
      : 'حالة غير معروفة من الخادم';

  static String get verificationDataUnavailable => isEnglish
      ? 'Verification data is unavailable'
      : 'بيانات التحقق غير متوفرة';

  static String get unableToFetchDriver => isEnglish
      ? 'Unable to retrieve driver profile'
      : 'تعذر جلب بيانات السائق';
}
