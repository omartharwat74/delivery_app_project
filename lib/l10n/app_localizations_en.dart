// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Driver App';

  @override
  String get changeAppLanguageTitle => 'Change App Language';

  @override
  String get languageArabicChip => 'عربي';

  @override
  String get languageEnglishChip => 'English';

  @override
  String get loginTitle => 'Sign in!';

  @override
  String get loginSubtitle =>
      'Enter your mobile number to complete the registration process';

  @override
  String get loginPhoneLabel => 'Mobile number';

  @override
  String get loginPhoneHint => 'Mobile number';

  @override
  String get loginSubmit => 'Confirm';

  @override
  String get loginNoAccount => 'New driver? ';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get biometricSoon => 'Biometric sign-in coming soon';

  @override
  String get otpTitle => 'Verification code';

  @override
  String get otpSubtitle =>
      'Enter the code sent to you to verify your mobile number.';

  @override
  String get otpVerify => 'Verify';

  @override
  String otpTimerSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get otpResend => 'Resend code?';

  @override
  String get otpResentSnackbar => 'Code sent again';

  @override
  String get registerWelcomeTitle => 'Welcome!';

  @override
  String get registerWelcomeSubtitle =>
      'Please enter the required registration details';

  @override
  String get registerProfilePhotoLabel => 'Profile photo';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameHint => 'Username';

  @override
  String get registerPhoneLabel => 'Mobile number';

  @override
  String get registerPhoneHint => 'Mobile number';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailHint => 'Email';

  @override
  String get registerNationalIdLabel => 'National ID';

  @override
  String get registerNationalIdHint => 'National ID';

  @override
  String get registerVehicleTypeLabel => 'Vehicle type';

  @override
  String get registerVehicleTypeHint => 'Type';

  @override
  String get registerVehicleNumberLabel => 'Vehicle number';

  @override
  String get registerVehicleNumberHint => 'Vehicle number';

  @override
  String get registerDeliveryAreaLabel => 'Delivery Area';

  @override
  String get registerDeliveryAreaHint => 'Select delivery area';

  @override
  String get registerDeliveryShiftLabel => 'Delivery Shift';

  @override
  String get registerDeliveryShiftHint => 'Select delivery shift';

  @override
  String get vehicleTypeMotorcycle => 'Motorcycle';

  @override
  String get vehicleTypeCar => 'Car';

  @override
  String get vehicleTypeBicycle => 'Bicycle';

  @override
  String get registerUploadDrivingLicense => 'Attach driving license photo';

  @override
  String get registerUploadVehicleLicense => 'Attach vehicle license photo';

  @override
  String get registerUploadNationalId => 'Attach national ID photo';

  @override
  String get registerUploadVehicleFront => 'Attach vehicle front photo';

  @override
  String get uploadTapToUpload => 'Tap to upload';

  @override
  String get uploadSuccessAdded => 'File added successfully';

  @override
  String get registerSubmit => 'Confirm';

  @override
  String get registerHasAccount => 'Already have an account? ';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get registrationPendingMessage =>
      'Your details were submitted and are awaiting admin approval.';

  @override
  String get validationUsernameRequired => 'Username is required';

  @override
  String get validationUsernameMin3 => 'Username must be at least 3 characters';

  @override
  String get validationPhoneRequired => 'Mobile number is required';

  @override
  String get validationPhoneEgyptian =>
      'Please enter a valid Egyptian mobile number';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationNationalIdRequired => 'National ID is required';

  @override
  String get validationNationalIdInvalid => 'National ID must be 14 digits';

  @override
  String get validationVehicleTypeRequired => 'Vehicle type is required';

  @override
  String get validationVehicleNumberRequired => 'Vehicle number is required';

  @override
  String get validationAreaRequired => 'Delivery area is required';

  @override
  String get validationShiftRequired => 'Delivery shift is required';

  @override
  String get validationDocumentRequired => 'Please upload this document';

  @override
  String get validationVehicleFrontRequired =>
      'Vehicle front photo is required';

  @override
  String get validationProfilePhotoRequired => 'Profile photo is required';

  @override
  String get validationFormCheckErrors =>
      'Please complete all required fields and documents correctly';

  @override
  String get validationOtpRequired => 'Verification code is required';

  @override
  String get validationOtpSixDigits => 'Please enter 6 digits';

  @override
  String get otpVerifyButton => 'Verify';

  @override
  String get otpResendCode => 'Resend Code?';

  @override
  String get otpSeconds => 'seconds';

  @override
  String get pendingSuccessTitle => 'Request submitted successfully';

  @override
  String get pendingSuccessSubtitle =>
      'Your request is being reviewed by the administration and will be answered as soon as possible';

  @override
  String get registerTitle => 'Register your data';

  @override
  String get registerSubtitle =>
      'Please complete the following data to complete the registration process';

  @override
  String get registerDriverLicense => 'Driver\'s license photo';

  @override
  String get registerNationalId => 'National ID / Iqama photo';

  @override
  String get registerCarRegistration => 'Car registration photo';

  @override
  String get registerSubmitButton => 'Submit Data';

  @override
  String get registerUploadPhoto => 'Upload photo here';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerOrders => 'Orders';

  @override
  String get drawerGeneralSettings => 'General Settings';

  @override
  String get drawerNotifications => 'Notifications';

  @override
  String get drawerReviews => 'Reviews';

  @override
  String get drawerWallet => 'Wallet';

  @override
  String get drawerSupport => 'Technical Support';

  @override
  String get drawerTerms => 'Terms & Conditions';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get drawerGuestName => 'User';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get currentBalance => 'Your current balance';

  @override
  String get withdrawButton => 'Withdraw';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get availableBalanceToWithdraw => 'Available Balance to Withdraw';

  @override
  String get currencyEgp => 'EGP';

  @override
  String get debtTitle => 'Debt';

  @override
  String get cashWithYou => '  (Cash with you)';

  @override
  String get withdrawBalanceButton => 'Withdraw Balance';

  @override
  String get transactionHistoryTitle => 'Transaction History : ';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String maxDebtLimitWarning(String amount) {
    return 'Your maximum debt limit is $amount EGP';
  }

  @override
  String get maxDebtWarningDetail =>
      'If exceeded, incoming orders will stop until you pay';

  @override
  String get pendingReviewBadge => 'Under Review';

  @override
  String get completedBadge => 'Completed';

  @override
  String get rejectedBadge => 'Rejected';

  @override
  String get withdrawalRequest => 'Withdrawal Request';

  @override
  String get cashOrder => 'Cash Order';

  @override
  String get cardOrder => 'Card Order';

  @override
  String get debtSettlement => 'Debt Settlement';

  @override
  String get appCommission => 'App Commission';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get withdrawBalanceModalTitle => 'Withdraw Balance';

  @override
  String get withdrawalAmountLabel => 'Withdrawal Amount';

  @override
  String get enterWithdrawalAmountHint => 'Enter withdrawal amount';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get withdrawalSuccessDialog =>
      'Your request has been sent to administration successfully';

  @override
  String get okButton => 'OK';

  @override
  String get enterValidAmount => 'Please enter a valid amount greater than 0';

  @override
  String get enterAmountPrompt => 'Please enter withdrawal amount';

  @override
  String amountExceedsBalance(String amount) {
    return 'Requested amount exceeds available balance ($amount EGP)';
  }

  @override
  String get walletTotal => 'Total';

  @override
  String get walletPaymentMethod => 'Payment Method';

  @override
  String get walletOrderDate => 'Order Date';

  @override
  String get walletOrderNumber => 'Order Number';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String get settingsUpdatedSuccess => 'Settings updated successfully';

  @override
  String get generalSettingsTitle => 'General Settings';

  @override
  String get changeAppLanguage => 'Change Language';

  @override
  String get arabicLanguage => 'Arabic';

  @override
  String get englishLanguage => 'English';

  @override
  String get notificationsControl => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmationTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmationMessage =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get supportChatTitle => 'Technical Support';

  @override
  String get supportToday => 'Today';

  @override
  String get supportGoodEvening => 'Good evening';

  @override
  String get supportHowCanWeHelp => 'How can we help you?';

  @override
  String get supportSampleUserIssue => 'I have an issue with the application.';

  @override
  String get supportInputHint => 'Write your message here...';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsBody =>
      'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don\'t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.\n\nThere are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don\'t look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn\'t anything embarrassing hidden in the middle of text.';

  @override
  String get changePhoneNumber => 'Change Phone Number';

  @override
  String get changePhoneTitle => 'Change Phone Number';

  @override
  String get changePhoneSubtitle =>
      'Enter your new phone number correctly to receive the verification code!';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get invalidPhoneMessage => 'Please enter your mobile number';

  @override
  String get invalidPhoneLengthMessage =>
      'Mobile number must be 11 or 12 digits';

  @override
  String get verifyPhoneTitle => 'Verification Code';

  @override
  String get verifyPhoneMessage =>
      'A verification code has been sent to your phone!';

  @override
  String get resendCode => 'Resend code?';

  @override
  String resendCodeTimer(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get phoneChangedTitle => 'Phone Number Changed Successfully';

  @override
  String get phoneChangedMessage =>
      'Your phone number has been updated successfully.';

  @override
  String get manageOrderReception => 'Manage Order Reception';

  @override
  String get currentPhoneLabel => 'Current Phone Number';

  @override
  String get newPhoneLabel => 'New Phone Number';

  @override
  String get verifyPhoneButton => 'Verify';

  @override
  String get enterCurrentPhone => 'Enter your current phone number';

  @override
  String get enterNewPhone => 'Enter your new phone number';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get phoneChangedSuccess => 'Phone number updated successfully';

  @override
  String get profilePersonalData => 'Personal Data';

  @override
  String get profileEditPersonalData => 'Edit Personal Data';

  @override
  String get profileRequestEdit => 'Request Edit';

  @override
  String get profileUserName => 'User Name';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileEmail => 'Email Address';

  @override
  String get profileNationalId => 'National ID';

  @override
  String get profileVehicleType => 'Vehicle Type';

  @override
  String get profileDriverLicense => 'Driver License Image';

  @override
  String get profileVehicleRegistration => 'Vehicle Registration Image';

  @override
  String get profileNationalIdImage => 'National ID Image';

  @override
  String get profileVehicleFront => 'Vehicle Front Image';

  @override
  String get profileUploadPrompt => 'Tap to upload';

  @override
  String get profileProfileImage => 'Profile Image';

  @override
  String trackingOrderNo(String id) {
    return 'Order No: #$id';
  }

  @override
  String trackingItems(String count) {
    return '$count Items';
  }

  @override
  String trackingFrom(String location) {
    return 'From: $location';
  }

  @override
  String trackingTo(String location) {
    return 'To: $location';
  }

  @override
  String trackingExpectedDistanceShort(String distance) {
    return '(approx $distance km)';
  }

  @override
  String trackingExpectedTotalDistance(String distance) {
    return 'Total expected distance $distance km';
  }

  @override
  String get trackingCustomerDetails => 'Customer Details :';

  @override
  String get trackingDeliveryScope => 'Delivery Range :';

  @override
  String get trackingConfirmPickup => 'Confirm Pickup';

  @override
  String get trackingConfirmDelivery => 'Confirm Delivery';

  @override
  String get trackingAcceptOrder => 'Accept Order';

  @override
  String get trackingMapOpen => 'Open Map';

  @override
  String get trackingNewOrderTitle => 'New Order Assigned';

  @override
  String get trackingNewOrderBody => 'You have a new delivery request';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get orderStatusAssigned => 'Assigned';

  @override
  String get orderStatusAssignedSub => 'Order Accepted';

  @override
  String get orderStatusOnWaySub => 'Driver on the way';

  @override
  String get orderStatusDeliveredSub => 'Delivered to customer';

  @override
  String get accountBlockedTitle => 'Account Blocked';

  @override
  String get accountBlockedMessage =>
      'Your account has been blocked. Contact support';

  @override
  String get accountBlockedHomeBanner =>
      'You are currently blocked, please contact technical support';

  @override
  String get shiftEndedForTodayError =>
      'You have ended your shift today, you cannot return to work until tomorrow';

  @override
  String get orderStatusNew => 'New Request';

  @override
  String get orderStatusPreparing => 'Restaurant Preparing';

  @override
  String get orderStatusReady => 'Ready for Pickup';

  @override
  String get orderStatusOnWay => 'On the way to Customer';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String orderFee(String fee) {
    return 'Fee: $fee';
  }

  @override
  String orderItemsCount(String count) {
    return '$count Items';
  }

  @override
  String get orderEstTime => 'Est. Time';

  @override
  String get minutes => 'mins';

  @override
  String get orderActive => 'Active';

  @override
  String get orderClosed => 'Closed';

  @override
  String get orderDetails => 'Details';

  @override
  String get mockRestaurantName1 => 'Az Al Sham';

  @override
  String get mockRestaurantName2 => 'Burger King';

  @override
  String get mockRestaurantName3 => 'Pizza Hut';

  @override
  String get mockUserName1 => 'Ahmad M.';

  @override
  String get mockUserName2 => 'Sarah K.';

  @override
  String get mockUserName3 => 'John D.';

  @override
  String mockReviewDate(String day) {
    return '2026/6/$day';
  }

  @override
  String mockReviewUserName(String id) {
    return 'User Name $id';
  }

  @override
  String get mockReviewText =>
      'This is a mock review text. The service was great and the delivery was fast. Highly recommended!';

  @override
  String get workingHoursTitle => 'Working Hours';

  @override
  String get specifiedShiftPeriod => 'Specified Working Period';

  @override
  String get fromTime => 'From';

  @override
  String get toTime => 'To';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get delete => 'Delete';

  @override
  String get deleting => 'Deleting...';

  @override
  String get confirmEdit => 'Confirm Edit';

  @override
  String get selectStartTimeTitle => 'Select Start Time (From)';

  @override
  String get selectEndTimeTitle => 'Select End Time (To)';

  @override
  String get lockedAppointmentWarning =>
      'Appointment is locked for editing or deletion (less than 6 hours)';

  @override
  String get deleteAppointmentConfirmTitle => 'Confirm Deletion';

  @override
  String get deleteAppointmentConfirmMessage =>
      'Are you sure you want to delete the working hours for this day?';

  @override
  String get deleteWorkingHoursSuccess => 'Working hours deleted successfully';

  @override
  String get updateWorkingHoursSuccess => 'Working hours updated successfully';

  @override
  String get editWorkingHoursSoon =>
      'Editing working hours will be supported soon';

  @override
  String get loadWorkingHoursError => 'Failed to load working hours';

  @override
  String get retry => 'Retry';

  @override
  String get locationPermissionDenied => 'Location permission was denied.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission is permanently denied. Please enable it from app settings.';

  @override
  String get locationServiceDisabled =>
      'Location services (GPS) are disabled. Please enable them to track your location.';

  @override
  String get openSettings => 'Settings';

  @override
  String get enableGps => 'Enable';

  @override
  String get orderReviewed => 'Reviewed';

  @override
  String get orderNotReviewed => 'Not Reviewed';
}
