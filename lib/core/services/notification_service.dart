import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  /// Requests notification permissions (essential for iOS and Android 13+).
  Future<NotificationSettings?> requestPermission();

  /// Retrieves the device FCM token. Returns null if permission is denied or token is unavailable.
  Future<String?> getFcmToken();
}

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging? _messaging;

  NotificationServiceImpl({FirebaseMessaging? messaging})
      : _messaging = messaging;

  FirebaseMessaging get _instance => _messaging ?? FirebaseMessaging.instance;

  @override
  Future<NotificationSettings?> requestPermission() async {
    try {
      final settings = await _instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      developer.log(
        'Notification permission status: ${settings.authorizationStatus}',
        name: 'NotificationService',
      );
      return settings;
    } catch (e, stack) {
      developer.log(
        'Error requesting notification permission: $e',
        error: e,
        stackTrace: stack,
        name: 'NotificationService',
      );
      return null;
    }
  }

  @override
  Future<String?> getFcmToken() async {
    try {
      await requestPermission();
      final token = await _instance.getToken();
      developer.log('Device FCM Token: $token', name: 'NotificationService');
      return token;
    } catch (e, stack) {
      developer.log(
        'Error retrieving FCM token: $e',
        error: e,
        stackTrace: stack,
        name: 'NotificationService',
      );
      return null;
    }
  }
}
