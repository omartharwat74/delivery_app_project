// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق السائق';

  @override
  String get changeAppLanguageTitle => 'تغيير لغة التطبيق';

  @override
  String get languageArabicChip => 'عربي';

  @override
  String get languageEnglishChip => 'English';

  @override
  String get loginTitle => 'تسجيل دخول !';

  @override
  String get loginSubtitle => 'أدخل رقم الجوال الخاص بك لإتمام عملية التسجيل';

  @override
  String get loginPhoneLabel => 'رقم الجوال';

  @override
  String get loginPhoneHint => 'رقم الجوال';

  @override
  String get loginSubmit => 'تأكيد';

  @override
  String get loginNoAccount => 'سائق جديد؟ ';

  @override
  String get loginCreateAccount => 'إنشاء حساب';

  @override
  String get biometricSoon => 'تسجيل الدخول بالبصمة قريباً';

  @override
  String get otpTitle => 'كود التحقق';

  @override
  String get otpSubtitle => 'أدخل الكود المرسل إليك للتأكد من رقم جوالك .';

  @override
  String get otpVerify => 'تحقق';

  @override
  String otpTimerSeconds(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get otpResend => 'إعادة إرسال الكود ؟';

  @override
  String get otpResentSnackbar => 'تم إرسال الكود مرة أخرى';

  @override
  String get registerWelcomeTitle => 'مرحباً بك !';

  @override
  String get registerWelcomeSubtitle => 'قم بإدخال بيانات التسجيل المطلوبة';

  @override
  String get registerProfilePhotoLabel => 'الصورة الشخصية';

  @override
  String get registerUsernameLabel => 'اسم المستخدم';

  @override
  String get registerUsernameHint => 'اسم المستخدم';

  @override
  String get registerPhoneLabel => 'رقم الجوال';

  @override
  String get registerPhoneHint => 'رقم الجوال';

  @override
  String get registerEmailLabel => 'البريد الالكتروني';

  @override
  String get registerEmailHint => 'البريد الالكتروني';

  @override
  String get registerNationalIdLabel => 'الرقم القومي';

  @override
  String get registerNationalIdHint => 'الرقم القومي';

  @override
  String get registerVehicleTypeLabel => 'نوع المركبة';

  @override
  String get registerVehicleTypeHint => 'النوع';

  @override
  String get registerVehicleNumberLabel => 'رقم المركبة';

  @override
  String get registerVehicleNumberHint => 'رقم المركبة';

  @override
  String get registerDeliveryAreaLabel => 'منطقة التوصيل';

  @override
  String get registerDeliveryAreaHint => 'اختر منطقة التوصيل';

  @override
  String get registerDeliveryShiftLabel => 'موعد التوصيل';

  @override
  String get registerDeliveryShiftHint => 'اختر موعد التوصيل';

  @override
  String get vehicleTypeMotorcycle => 'دراجة نارية';

  @override
  String get vehicleTypeCar => 'سيارة';

  @override
  String get vehicleTypeBicycle => 'دراجة';

  @override
  String get registerUploadDrivingLicense => 'إرفق صوره رخصه القيادة';

  @override
  String get registerUploadVehicleLicense => 'إرفق صوره رخصه المركبة';

  @override
  String get registerUploadNationalId => 'ارفق صوره الهويه الوطنيه';

  @override
  String get registerUploadVehicleFront => 'إرفاق صورة الدراجة من الأمام';

  @override
  String get uploadTapToUpload => 'اضغط للرفع';

  @override
  String get uploadSuccessAdded => 'تم إضافة الملف بنجاح';

  @override
  String get registerSubmit => 'تأكيد';

  @override
  String get registerHasAccount => 'هل لديك حساب من قبل؟ ';

  @override
  String get registerSignIn => 'تسجيل دخول';

  @override
  String get registrationPendingMessage =>
      'تم إرسال بياناتك وبإنتظار موافقة الادارة';

  @override
  String get validationUsernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get validationUsernameMin3 => 'اسم المستخدم يجب ألا يقل عن ٣ أحرف';

  @override
  String get validationPhoneRequired => 'رقم الجوال مطلوب';

  @override
  String get validationPhoneEgyptian => 'يرجى إدخال رقم جوال مصري صحيح';

  @override
  String get validationEmailRequired => 'البريد الالكتروني مطلوب';

  @override
  String get validationEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get validationNationalIdRequired => 'الرقم القومي مطلوب';

  @override
  String get validationNationalIdInvalid => 'الرقم القومي يجب أن يكون ١٤ رقماً';

  @override
  String get validationVehicleTypeRequired => 'نوع المركبة مطلوب';

  @override
  String get validationVehicleNumberRequired => 'رقم المركبة مطلوب';

  @override
  String get validationAreaRequired => 'منطقة التوصيل مطلوبة';

  @override
  String get validationShiftRequired => 'موعد التوصيل مطلوب';

  @override
  String get validationDocumentRequired => 'يرجى رفع هذا المستند';

  @override
  String get validationVehicleFrontRequired => 'صورة الدراجة من الأمام مطلوبة';

  @override
  String get validationProfilePhotoRequired => 'الصورة الشخصية مطلوبة';

  @override
  String get validationFormCheckErrors =>
      'يرجى استكمال جميع الحقول والمستندات المطلوبة والتأكد من صحتها';

  @override
  String get validationOtpRequired => 'رمز التحقق مطلوب';

  @override
  String get validationOtpSixDigits => 'يرجى إدخال ٦ أرقام';

  @override
  String get otpVerifyButton => 'تحقق';

  @override
  String get otpResendCode => 'إعادة إرسال الكود ؟';

  @override
  String get otpSeconds => 'ثانية';

  @override
  String get pendingSuccessTitle => 'تم تقديم الطلب بنجاح';

  @override
  String get pendingSuccessSubtitle =>
      'جاري مراجعة طلبك من قبل الإدارة وسيتم الرد عليك في أقرب وقت ممكن';

  @override
  String get registerTitle => 'تسجيل بياناتك';

  @override
  String get registerSubtitle =>
      'يرجى استكمال البيانات التالية لإتمام عملية التسجيل';

  @override
  String get registerDriverLicense => 'صورة رخصة القيادة';

  @override
  String get registerNationalId => 'صورة الهوية الوطنية / الإقامة';

  @override
  String get registerCarRegistration => 'صورة استمارة السيارة';

  @override
  String get registerSubmitButton => 'إرسال البيانات';

  @override
  String get registerUploadPhoto => 'قم برفع الصورة من هنا';

  @override
  String get drawerHome => 'الرئيسية';

  @override
  String get drawerOrders => 'الطلبات';

  @override
  String get drawerGeneralSettings => 'الإعدادات العامة';

  @override
  String get drawerNotifications => 'الإشعارات';

  @override
  String get drawerReviews => 'التقييمات';

  @override
  String get drawerWallet => 'المحفظة';

  @override
  String get drawerSupport => 'الدعم الفني';

  @override
  String get drawerTerms => 'الشروط والأحكام';

  @override
  String get drawerLogout => 'تسجيل الخروج';

  @override
  String get noReviewsYet => 'لا توجد تقييمات حتى الآن.';

  @override
  String get noNotificationsYet => 'لا يوجد اشعارات حتى الآن';

  @override
  String get drawerGuestName => 'مستخدم';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get currentBalance => 'رصيدك الحالي';

  @override
  String get withdrawButton => 'سحب';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get availableBalanceToWithdraw => 'الرصيد المتاح للسحب';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get debtTitle => 'المديونية';

  @override
  String get cashWithYou => '  (كاش معاك)';

  @override
  String get withdrawBalanceButton => 'سحب الرصيد';

  @override
  String get transactionHistoryTitle => 'سجل المعاملات : ';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noTransactionsYet => 'لا توجد معاملات حتى الآن';

  @override
  String maxDebtLimitWarning(String amount) {
    return 'الحد الأعلى للمديونية عليك $amount جنيه';
  }

  @override
  String get maxDebtWarningDetail =>
      'في حالة الزيادة تتوقف الطلبات من الوصول إليك حتى تقوم بالسداد';

  @override
  String get pendingReviewBadge => 'قيد المراجعة';

  @override
  String get completedBadge => 'منتهي';

  @override
  String get rejectedBadge => 'مرفوض';

  @override
  String get withdrawalRequest => 'طلب سحب';

  @override
  String get cashOrder => 'طلب كاش';

  @override
  String get cardOrder => 'طلب فيزا';

  @override
  String get debtSettlement => 'تسديد مديونية';

  @override
  String get appCommission => 'عمولة التطبيق';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get withdrawBalanceModalTitle => 'سحب رصيد';

  @override
  String get withdrawalAmountLabel => 'مبلغ السحب';

  @override
  String get enterWithdrawalAmountHint => 'ادخل مبلغ السحب';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get withdrawalSuccessDialog => 'تم إرسال طلبك الى الادارة بنجاح';

  @override
  String get okButton => 'حسناً';

  @override
  String get enterValidAmount => 'يرجى إدخال مبلغ صالح أكبر من 0';

  @override
  String get enterAmountPrompt => 'يرجى إدخال مبلغ السحب';

  @override
  String amountExceedsBalance(String amount) {
    return 'المبلغ المطلوب يتجاوز الرصيد المتاح ($amount ج.م)';
  }

  @override
  String get walletTotal => 'الاجمالي';

  @override
  String get walletPaymentMethod => 'طريقة الدفع';

  @override
  String get walletOrderDate => 'تاريخ الطلب';

  @override
  String get walletOrderNumber => 'رقم الطلب';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteAccountSuccess => 'تم حذف الحساب بنجاح';

  @override
  String get settingsUpdatedSuccess => 'تم تحديث الإعدادات بنجاح';

  @override
  String get generalSettingsTitle => 'الإعدادات العامة';

  @override
  String get changeAppLanguage => 'تغيير لغة التطبيق';

  @override
  String get arabicLanguage => 'عربي';

  @override
  String get englishLanguage => 'English';

  @override
  String get notificationsControl => 'الإشعارات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmationTitle => 'حذف الحساب';

  @override
  String get deleteAccountConfirmationMessage =>
      'هل أنت متأكد من حذف الحساب؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get supportChatTitle => 'الدعم الفني';

  @override
  String get supportToday => 'اليوم';

  @override
  String get supportGoodEvening => 'مساء الخير';

  @override
  String get supportHowCanWeHelp => 'كيف يمكننا مساعدتك؟';

  @override
  String get supportSampleUserIssue => 'لدي مشكلة في التطبيق.';

  @override
  String get supportInputHint => 'اكتب رسالتك هنا...';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get termsBody =>
      'هنالك العديد من الأنواع المتوفرة لنصوص لوريم إيبسوم، ولكن الغالبية تم تعديلها بشكل ما عبر إدخال بعض النوادر أو الكلمات العشوائية إلى النص. إن كنت تريد أن تستخدم نص لوريم إيبسوم ما، عليك أن تتحقق أولاً أن ليس هناك أي كلمات أو عبارات محرجة أو غير لائقة مخبأة في هذا النص. بينما تعمل بعض مولّدات نصوص لوريم إيبسوم على الإنترنت على إعادة تكرار مقاطع من نص لوريم إيبسوم نفسه عدة مرات بما تتطلبه الحاجة، فأن البعض الأخر يستخدم كلمات من قاموس يحوي على أكثر من 200 كلمة لا تينية، مضاف هنالك العديد من الأنواع المتوفرة لنصوص لوريم إيبسوم، ولكن الغالبية تم تعديلها بشكل ما عبر إدخال بعض النوادر أو الكلمات العشوائية إلى النص. إن كنت تريد أن تستخدم نص لوريم إيبسوم ما، عليك أن تتحقق أولاً أن ليس هناك أي كلمات أو عبارات محرجة أو غير لائقة مخبأة في هذا النص. بينما تعمل بعض مولّدات نصوص لوريم إيبسوم على الإنترنت على إعادة تكرار مقاطع من نص لوريم إيبسوم نفسه عدة مرات بما تتطلبه الحاجة، فأن البعض الأخر يستخدم كلمات من قاموس يحوي على أكثر من 200 كلمة لا تينية، مضاف هنالك العديد من الأنواع المتوفرة لنصوص لوريم إيبسوم، ولكن الغالبية تم تعديلها بشكل ما عبر إدخال بعض النوادر أو الكلمات العشوائية إلى النص. إن كنت تريد أن تستخدم نص لوريم إيبسوم ما، عليك أن تتحقق أولاً أن ليس هناك أي كلمات أو عبارات محرجة أو غير لائقة مخبأة في هذا النص. بينما تعمل بعض مولّدات نصوص لوريم إيبسوم على الإنترنت على إعادة تكرار مقاطع من نص لوريم إيبسوم نفسه عدة مرات بما تتطلبه الحاجة، فأن البعض الأخر يستخدم كلمات من قاموس يحوي على أكثر من 200 كلمة لا تينية، مضاف\n\nإعادة تكرار مقاطع من نص لوريم إيبسوم نفسه عدة مرات بما تتطلبه الحاجة، فأن البعض الأخر يستخدم كلمات من قاموس يحوي على أكثر من 200 كلمة لا تينية، مضاف';

  @override
  String get changePhoneNumber => 'تغيير رقم الجوال';

  @override
  String get changePhoneTitle => 'تغيير رقم الجوال';

  @override
  String get changePhoneSubtitle =>
      'ادخل رقمك الجديد بشكل صحيح ليصلك كود التفعيل !';

  @override
  String get mobileNumber => 'رقم الجوال';

  @override
  String get invalidPhoneMessage => 'يرجى إدخال رقم الجوال';

  @override
  String get invalidPhoneLengthMessage => 'رقم الجوال يجب أن يكون 11 أو 12 رقم';

  @override
  String get verifyPhoneTitle => 'كود التحقق';

  @override
  String get verifyPhoneMessage => 'تم إرسال كود على رقمك للتحقق !';

  @override
  String get resendCode => 'إعادة إرسال الكود ؟';

  @override
  String resendCodeTimer(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String get phoneChangedTitle => 'تم تغيير رقم الجوال بنجاح';

  @override
  String get phoneChangedMessage => 'تم تحديث رقم الجوال بنجاح.';

  @override
  String get manageOrderReception => 'التحكم في استقبال الطلبات';

  @override
  String get currentPhoneLabel => 'رقم الجوال الحالي';

  @override
  String get newPhoneLabel => 'رقم الجوال الجديد';

  @override
  String get verifyPhoneButton => 'تأكيد';

  @override
  String get enterCurrentPhone => 'أدخل رقم جوالك الحالي';

  @override
  String get enterNewPhone => 'أدخل رقم جوالك الجديد';

  @override
  String get invalidPhone => 'رقم الجوال غير صحيح';

  @override
  String get phoneChangedSuccess => 'تم تحديث رقم الجوال بنجاح';

  @override
  String get profilePersonalData => 'البيانات الشخصية';

  @override
  String get profileEditPersonalData => 'تعديل البيانات الشخصية';

  @override
  String get profileRequestEdit => 'طلب تعديل';

  @override
  String get profileUserName => 'اسم المستخدم';

  @override
  String get profilePhone => 'رقم الجوال';

  @override
  String get profileEmail => 'البريد الالكتروني';

  @override
  String get profileNationalId => 'الرقم القومي';

  @override
  String get profileVehicleType => 'نوع المركبة';

  @override
  String get profileDriverLicense => 'صوره رخصه القيادة';

  @override
  String get profileVehicleRegistration => 'صوره رخصه المركبة';

  @override
  String get profileNationalIdImage => 'صوره الهويه الوطنيه';

  @override
  String get profileVehicleFront => 'صورة الدراجة من الأمام';

  @override
  String get profileUploadPrompt => 'اضغط للرفع';

  @override
  String get profileProfileImage => 'الصورة الشخصية';

  @override
  String trackingOrderNo(String id) {
    return 'طلب رقم : #$id';
  }

  @override
  String trackingItems(String count) {
    return '$count منتجات';
  }

  @override
  String trackingFrom(String location) {
    return 'من : $location';
  }

  @override
  String trackingTo(String location) {
    return 'الى : $location';
  }

  @override
  String trackingExpectedDistanceShort(String distance) {
    return '(حوالي $distance كم)';
  }

  @override
  String trackingExpectedTotalDistance(String distance) {
    return 'اجمالي المسافة المتوقعة $distance كم';
  }

  @override
  String get trackingCustomerDetails => 'بيانات العميل :';

  @override
  String get trackingConfirmPickup => 'تم استلام الطلب';

  @override
  String get trackingConfirmDelivery => 'تم تسليم الطلب';

  @override
  String get trackingMapOpen => 'فتح الخريطة';

  @override
  String get trackingNewOrderTitle => 'طلب جديد';

  @override
  String get trackingNewOrderBody => 'لديك طلب توصيل جديد';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String get orderStatusNew => 'طلب جديد';

  @override
  String get orderStatusPreparing => 'جاري التجهيز';

  @override
  String get orderStatusReady => 'جاهز للاستلام';

  @override
  String get orderStatusOnWay => 'في الطريق للعميل';

  @override
  String get orderStatusDelivered => 'تم التوصيل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String orderFee(String fee) {
    return 'الرسوم: $fee';
  }

  @override
  String orderItemsCount(String count) {
    return '$count منتجات';
  }

  @override
  String get orderEstTime => 'الوقت المتوقع';

  @override
  String get orderActive => 'نشط';

  @override
  String get orderClosed => 'مغلق';

  @override
  String get orderDetails => 'التفاصيل';

  @override
  String get mockRestaurantName1 => 'عز الشام';

  @override
  String get mockRestaurantName2 => 'برجر كنج';

  @override
  String get mockRestaurantName3 => 'بيتزا هت';

  @override
  String get mockUserName1 => 'أحمد م.';

  @override
  String get mockUserName2 => 'سارة ك.';

  @override
  String get mockUserName3 => 'جون د.';

  @override
  String mockReviewDate(String day) {
    return '2026/6/$day';
  }

  @override
  String mockReviewUserName(String id) {
    return 'مستخدم $id';
  }

  @override
  String get mockReviewText =>
      'هذا نص تقييم تجريبي. الخدمة كانت ممتازة والتوصيل سريع. أنصح به بشدة!';

  @override
  String get workingHoursTitle => 'مواعيد العمل';

  @override
  String get specifiedShiftPeriod => 'فترة العمل المحددة';

  @override
  String get fromTime => 'من';

  @override
  String get toTime => 'الى';

  @override
  String get editAppointment => 'تعديل الموعد';

  @override
  String get delete => 'حذف';

  @override
  String get deleting => 'جاري الحذف...';

  @override
  String get confirmEdit => 'تأكيد التعديل';

  @override
  String get selectStartTimeTitle => 'تحديد وقت البداية (من)';

  @override
  String get selectEndTimeTitle => 'تحديد وقت النهاية (الى)';

  @override
  String get lockedAppointmentWarning =>
      'الموعد مغلق للتعديل أو الحذف (أقل من 6 ساعات)';

  @override
  String get deleteAppointmentConfirmTitle => 'تأكيد الحذف';

  @override
  String get deleteAppointmentConfirmMessage =>
      'هل أنت متأكد من رغبتك في حذف موعد العمل لهذا اليوم؟';

  @override
  String get deleteWorkingHoursSuccess => 'تم حذف موعد العمل بنجاح';

  @override
  String get updateWorkingHoursSuccess => 'تم تعديل موعد العمل بنجاح';

  @override
  String get editWorkingHoursSoon =>
      'سيتم تفعيل تعديل المواعيد قريباً من خلال الخادم';

  @override
  String get loadWorkingHoursError => 'حدث خطأ في تحميل مواعيد العمل';

  @override
  String get retry => 'إعادة المحاولة';
}
