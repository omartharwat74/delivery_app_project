import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver App'**
  String get appTitle;

  /// No description provided for @changeAppLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Change App Language'**
  String get changeAppLanguageTitle;

  /// No description provided for @languageArabicChip.
  ///
  /// In en, this message translates to:
  /// **'عربي'**
  String get languageArabicChip;

  /// No description provided for @languageEnglishChip.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishChip;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to complete the registration process'**
  String get loginSubtitle;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get loginPhoneHint;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get loginSubmit;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'New driver? '**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @biometricSoon.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in coming soon'**
  String get biometricSoon;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to you to verify your mobile number.'**
  String get otpSubtitle;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpTimerSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String otpTimerSeconds(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code?'**
  String get otpResend;

  /// No description provided for @otpResentSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Code sent again'**
  String get otpResentSnackbar;

  /// No description provided for @registerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get registerWelcomeTitle;

  /// No description provided for @registerWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter the required registration details'**
  String get registerWelcomeSubtitle;

  /// No description provided for @registerProfilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get registerProfilePhotoLabel;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameHint;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get registerPhoneLabel;

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get registerPhoneHint;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailHint;

  /// No description provided for @registerNationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get registerNationalIdLabel;

  /// No description provided for @registerNationalIdHint.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get registerNationalIdHint;

  /// No description provided for @registerVehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get registerVehicleTypeLabel;

  /// No description provided for @registerVehicleTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get registerVehicleTypeHint;

  /// No description provided for @registerVehicleNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number'**
  String get registerVehicleNumberLabel;

  /// No description provided for @registerVehicleNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number'**
  String get registerVehicleNumberHint;

  /// No description provided for @registerDeliveryAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Area'**
  String get registerDeliveryAreaLabel;

  /// No description provided for @registerDeliveryAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Select delivery area'**
  String get registerDeliveryAreaHint;

  /// No description provided for @registerDeliveryShiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Shift'**
  String get registerDeliveryShiftLabel;

  /// No description provided for @registerDeliveryShiftHint.
  ///
  /// In en, this message translates to:
  /// **'Select delivery shift'**
  String get registerDeliveryShiftHint;

  /// No description provided for @vehicleTypeMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleTypeMotorcycle;

  /// No description provided for @vehicleTypeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleTypeCar;

  /// No description provided for @vehicleTypeBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get vehicleTypeBicycle;

  /// No description provided for @registerUploadDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Attach driving license photo'**
  String get registerUploadDrivingLicense;

  /// No description provided for @registerUploadVehicleLicense.
  ///
  /// In en, this message translates to:
  /// **'Attach vehicle license photo'**
  String get registerUploadVehicleLicense;

  /// No description provided for @registerUploadNationalId.
  ///
  /// In en, this message translates to:
  /// **'Attach national ID photo'**
  String get registerUploadNationalId;

  /// No description provided for @registerUploadVehicleFront.
  ///
  /// In en, this message translates to:
  /// **'Attach vehicle front photo'**
  String get registerUploadVehicleFront;

  /// No description provided for @uploadTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get uploadTapToUpload;

  /// No description provided for @uploadSuccessAdded.
  ///
  /// In en, this message translates to:
  /// **'File added successfully'**
  String get uploadSuccessAdded;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get registerSubmit;

  /// No description provided for @registerHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHasAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @registrationPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your details were submitted and are awaiting admin approval.'**
  String get registrationPendingMessage;

  /// No description provided for @validationUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get validationUsernameRequired;

  /// No description provided for @validationUsernameMin3.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get validationUsernameMin3;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Egyptian mobile number'**
  String get validationPhoneEgyptian;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationNationalIdRequired.
  ///
  /// In en, this message translates to:
  /// **'National ID is required'**
  String get validationNationalIdRequired;

  /// No description provided for @validationNationalIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'National ID must be 14 digits'**
  String get validationNationalIdInvalid;

  /// No description provided for @validationVehicleTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type is required'**
  String get validationVehicleTypeRequired;

  /// No description provided for @validationVehicleNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get validationVehicleNumberRequired;

  /// No description provided for @validationAreaRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery area is required'**
  String get validationAreaRequired;

  /// No description provided for @validationShiftRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery shift is required'**
  String get validationShiftRequired;

  /// No description provided for @validationDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload this document'**
  String get validationDocumentRequired;

  /// No description provided for @validationVehicleFrontRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle front photo is required'**
  String get validationVehicleFrontRequired;

  /// No description provided for @validationProfilePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile photo is required'**
  String get validationProfilePhotoRequired;

  /// No description provided for @validationFormCheckErrors.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields and documents correctly'**
  String get validationFormCheckErrors;

  /// No description provided for @validationOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get validationOtpRequired;

  /// No description provided for @validationOtpSixDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter 6 digits'**
  String get validationOtpSixDigits;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code?'**
  String get otpResendCode;

  /// No description provided for @otpSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get otpSeconds;

  /// No description provided for @pendingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get pendingSuccessTitle;

  /// No description provided for @pendingSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request is being reviewed by the administration and will be answered as soon as possible'**
  String get pendingSuccessSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register your data'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please complete the following data to complete the registration process'**
  String get registerSubtitle;

  /// No description provided for @registerDriverLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license photo'**
  String get registerDriverLicense;

  /// No description provided for @registerNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID / Iqama photo'**
  String get registerNationalId;

  /// No description provided for @registerCarRegistration.
  ///
  /// In en, this message translates to:
  /// **'Car registration photo'**
  String get registerCarRegistration;

  /// No description provided for @registerSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Data'**
  String get registerSubmitButton;

  /// No description provided for @registerUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo here'**
  String get registerUploadPhoto;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get drawerOrders;

  /// No description provided for @drawerGeneralSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get drawerGeneralSettings;

  /// No description provided for @drawerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get drawerNotifications;

  /// No description provided for @drawerReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get drawerReviews;

  /// No description provided for @drawerWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get drawerWallet;

  /// No description provided for @drawerSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get drawerSupport;

  /// No description provided for @drawerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get drawerTerms;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @drawerGuestName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get drawerGuestName;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Your current balance'**
  String get currentBalance;

  /// No description provided for @withdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawButton;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @walletTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get walletTotal;

  /// No description provided for @walletPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get walletPaymentMethod;

  /// No description provided for @walletOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get walletOrderDate;

  /// No description provided for @walletOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get walletOrderNumber;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// No description provided for @settingsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get settingsUpdatedSuccess;

  /// No description provided for @generalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettingsTitle;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeAppLanguage;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @notificationsControl.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsControl;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmationMessage;

  /// No description provided for @supportChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get supportChatTitle;

  /// No description provided for @supportToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get supportToday;

  /// No description provided for @supportGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get supportGoodEvening;

  /// No description provided for @supportHowCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get supportHowCanWeHelp;

  /// No description provided for @supportSampleUserIssue.
  ///
  /// In en, this message translates to:
  /// **'I have an issue with the application.'**
  String get supportSampleUserIssue;

  /// No description provided for @supportInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get supportInputHint;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don\'t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.\n\nThere are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don\'t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t anything embarrassing hidden in the middle of text.'**
  String get termsBody;

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneNumber;

  /// No description provided for @changePhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneTitle;

  /// No description provided for @changePhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new phone number correctly to receive the verification code!'**
  String get changePhoneSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @invalidPhoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get invalidPhoneMessage;

  /// No description provided for @invalidPhoneLengthMessage.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 11 or 12 digits'**
  String get invalidPhoneLengthMessage;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyPhoneMessage.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent to your phone!'**
  String get verifyPhoneMessage;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code?'**
  String get resendCode;

  /// No description provided for @resendCodeTimer.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String resendCodeTimer(int seconds);

  /// No description provided for @phoneChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Number Changed Successfully'**
  String get phoneChangedTitle;

  /// No description provided for @phoneChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your phone number has been updated successfully.'**
  String get phoneChangedMessage;

  /// No description provided for @manageOrderReception.
  ///
  /// In en, this message translates to:
  /// **'Manage Order Reception'**
  String get manageOrderReception;

  /// No description provided for @currentPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Phone Number'**
  String get currentPhoneLabel;

  /// No description provided for @newPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'New Phone Number'**
  String get newPhoneLabel;

  /// No description provided for @verifyPhoneButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyPhoneButton;

  /// No description provided for @enterCurrentPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your current phone number'**
  String get enterCurrentPhone;

  /// No description provided for @enterNewPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your new phone number'**
  String get enterNewPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @phoneChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated successfully'**
  String get phoneChangedSuccess;

  /// No description provided for @profilePersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get profilePersonalData;

  /// No description provided for @profileEditPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Data'**
  String get profileEditPersonalData;

  /// No description provided for @profileRequestEdit.
  ///
  /// In en, this message translates to:
  /// **'Request Edit'**
  String get profileRequestEdit;

  /// No description provided for @profileUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get profileUserName;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmail;

  /// No description provided for @profileNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get profileNationalId;

  /// No description provided for @profileVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get profileVehicleType;

  /// No description provided for @profileDriverLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver License Image'**
  String get profileDriverLicense;

  /// No description provided for @profileVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration Image'**
  String get profileVehicleRegistration;

  /// No description provided for @profileNationalIdImage.
  ///
  /// In en, this message translates to:
  /// **'National ID Image'**
  String get profileNationalIdImage;

  /// No description provided for @profileVehicleFront.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Front Image'**
  String get profileVehicleFront;

  /// No description provided for @profileUploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get profileUploadPrompt;

  /// No description provided for @profileProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile Image'**
  String get profileProfileImage;

  /// No description provided for @trackingOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No: #{id}'**
  String trackingOrderNo(String id);

  /// No description provided for @trackingItems.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String trackingItems(String count);

  /// No description provided for @trackingFrom.
  ///
  /// In en, this message translates to:
  /// **'From: {location}'**
  String trackingFrom(String location);

  /// No description provided for @trackingTo.
  ///
  /// In en, this message translates to:
  /// **'To: {location}'**
  String trackingTo(String location);

  /// No description provided for @trackingExpectedDistanceShort.
  ///
  /// In en, this message translates to:
  /// **'(approx {distance} km)'**
  String trackingExpectedDistanceShort(String distance);

  /// No description provided for @trackingExpectedTotalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total expected distance {distance} km'**
  String trackingExpectedTotalDistance(String distance);

  /// No description provided for @trackingCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details :'**
  String get trackingCustomerDetails;

  /// No description provided for @trackingConfirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup'**
  String get trackingConfirmPickup;

  /// No description provided for @trackingConfirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get trackingConfirmDelivery;

  /// No description provided for @trackingMapOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get trackingMapOpen;

  /// No description provided for @trackingNewOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'New Order Assigned'**
  String get trackingNewOrderTitle;

  /// No description provided for @trackingNewOrderBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new delivery request'**
  String get trackingNewOrderBody;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @orderStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get orderStatusNew;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get orderStatusReady;

  /// No description provided for @orderStatusOnWay.
  ///
  /// In en, this message translates to:
  /// **'On the way to Customer'**
  String get orderStatusOnWay;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderFee.
  ///
  /// In en, this message translates to:
  /// **'Fee: {fee}'**
  String orderFee(String fee);

  /// No description provided for @orderItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String orderItemsCount(String count);

  /// No description provided for @orderEstTime.
  ///
  /// In en, this message translates to:
  /// **'Est. Time'**
  String get orderEstTime;

  /// No description provided for @orderActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderActive;

  /// No description provided for @orderClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get orderClosed;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get orderDetails;

  /// No description provided for @mockRestaurantName1.
  ///
  /// In en, this message translates to:
  /// **'Az Al Sham'**
  String get mockRestaurantName1;

  /// No description provided for @mockRestaurantName2.
  ///
  /// In en, this message translates to:
  /// **'Burger King'**
  String get mockRestaurantName2;

  /// No description provided for @mockRestaurantName3.
  ///
  /// In en, this message translates to:
  /// **'Pizza Hut'**
  String get mockRestaurantName3;

  /// No description provided for @mockUserName1.
  ///
  /// In en, this message translates to:
  /// **'Ahmad M.'**
  String get mockUserName1;

  /// No description provided for @mockUserName2.
  ///
  /// In en, this message translates to:
  /// **'Sarah K.'**
  String get mockUserName2;

  /// No description provided for @mockUserName3.
  ///
  /// In en, this message translates to:
  /// **'John D.'**
  String get mockUserName3;

  /// No description provided for @mockReviewDate.
  ///
  /// In en, this message translates to:
  /// **'2026/6/{day}'**
  String mockReviewDate(String day);

  /// No description provided for @mockReviewUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name {id}'**
  String mockReviewUserName(String id);

  /// No description provided for @mockReviewText.
  ///
  /// In en, this message translates to:
  /// **'This is a mock review text. The service was great and the delivery was fast. Highly recommended!'**
  String get mockReviewText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
