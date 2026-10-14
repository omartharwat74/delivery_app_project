class ApiConstants {
  static const String baseUrl = 'https://mycar.msarweb.net/api/delivery/v1';
  static const Duration timeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String sendOtp = '/auth/phone/send-otp';
  static const String verifyOtp = '/auth/phone/verify-otp';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String updateFcm = '/auth/update-fcm';
  static const String location = '/auth/location';
  // Attendance Endpoints
  static const String availability = '/attendance/availability';

  // Lookups Endpoints
  static const String lookupsAreas = '/lookups/areas';
  static const String lookupsShifts = '/lookups/shifts';

  // General Settings
  static const String generalSettings = '/general-settings';

  // Profile Endpoints
  static const String profile = '/profile/show';
  static const String profileNotifications = '/profile/notifications';
  static const String sendCurrentOtp = '/profile/phone/send-current-otp';
  static const String verifyCurrentOtp = '/profile/phone/verify-current-otp';
  static const String profileSendOtp = '/profile/phone/send-otp';
  static const String profileVerifyOtp = '/profile/phone/verify-otp';
  static const String payout = '/profile/payout';

  // Notifications
  static const String notifications = '/notifications';

  // Working Hours
  static const String workingHours = '/working-hours';

  // Reviews
  static const String reviews = '/reviews';
  static const String reportReview = '/reviews/report';

  // Support
  static const String support = '/support';
  static const String supportMessages = '/support/messages';
  static const String supportHistory = '/support/history';

  // Legacy mappings for backwards compatibility with existing UI/datasources
  static const String driverStatus = availability;
  static const String todayStats = '/today-stats';
  static const String shifts = lookupsShifts;
  static const String activeOrder = '/orders/active';
  static const String acceptOrder = '/orders/{id}/accept';
  static const String declineOrder = '/orders/{id}/decline';
  static const String arrivedOrder = '/orders/{id}/arrived';
  static const String confirmOrder = '/orders/{id}/confirm';
  static const String reportIssue = '/orders/{id}/issue';
  static const String driverLocation = location;
  static const String earnings = '/earnings';
  static const String earningsHistory = '/earnings/history';
  static const String incentives = '/incentives';
  static const String performance = '/performance';
  static const String withdrawal = '/earnings/withdraw';
  static const String surgeZones = '/surge-zones';
  static const String documents = '/driver/documents';
  static const String uploadMedia = '/media/upload';
}
