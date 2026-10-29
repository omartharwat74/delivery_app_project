import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationService {
  /// Requests notification permissions (essential for iOS and Android 13+).
  Future<NotificationSettings?> requestPermission();

  /// Retrieves the device FCM token. Returns null if permission is denied or token is unavailable.
  Future<String?> getFcmToken();

  /// Stream of new FCM token values whenever Google refreshes it.
  Stream<String> get onTokenRefresh;

  /// Stream of incoming foreground messages.
  Stream<RemoteMessage> get onMessage;

  /// Stream of messages that caused the app to open from the background.
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// Retrieves any message that opened the app from a terminated state.
  Future<RemoteMessage?> getInitialMessage();

  /// Initializes listeners for token refresh and incoming notifications.
  Future<void> initialize({
    void Function(String token)? onTokenRefresh,
    VoidCallback? onOrderOfferChime,
  });
}

class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging? _messaging;

  NotificationServiceImpl({FirebaseMessaging? messaging})
      : _messaging = messaging;

  FirebaseMessaging get _instance => _messaging ?? FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

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
      debugPrint('🔔 [FCM] Device Token: $token');
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

  @override
  Stream<String> get onTokenRefresh => _instance.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() => _instance.getInitialMessage();

  @override
  Future<void> initialize({
    void Function(String token)? onTokenRefresh,
    VoidCallback? onOrderOfferChime,
  }) async {
    try {
      // 1. Request permission
      final settings = await requestPermission();

      // If permissions were granted, fetch token immediately and update backend
      if (settings != null &&
          (settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional)) {
        try {
          final token = await _instance.getToken();
          if (token != null && token.isNotEmpty && onTokenRefresh != null) {
            onTokenRefresh(token);
          }
        } catch (_) {}
      }

      // 2. Configure foreground presentation options (iOS & Android)
      await _instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Listen to token refresh
      if (onTokenRefresh != null) {
        _tokenRefreshSub?.cancel();
        _tokenRefreshSub = this.onTokenRefresh.listen((token) {
          developer.log('FCM Token Refreshed: $token', name: 'NotificationService');
          onTokenRefresh(token);
        });
      }

      void handleMessage(RemoteMessage message, String source) {
        developer.log(
          'FCM Message ($source): title=${message.notification?.title}, data=${message.data}',
          name: 'NotificationService',
        );
        debugPrint('🔔 [FCM Message - $source] Title: "${message.notification?.title}", Data: ${message.data}');
        final title = message.notification?.title ?? '';
        // If notification title indicates "طلب جديد" or data payload is empty (per business requirement)
        // or any order notification arrives, immediately fetch current offer:
        final isNewOrderNotification = title.contains('طلب جديد') ||
            title.toLowerCase().contains('new order') ||
            title.contains('طلب') ||
            message.data.isEmpty;

        if (isNewOrderNotification) {
          debugPrint('🚀 [FCM Action] "طلب جديد" detected -> trigger GET /orders/offer immediately');
          onOrderOfferChime?.call();
        }
      }

      // 4. Foreground message listener
      _foregroundSub?.cancel();
      _foregroundSub = onMessage.listen((message) {
        handleMessage(message, 'foreground');
      });

      // 5. Background message clicked
      _openedAppSub?.cancel();
      _openedAppSub = onMessageOpenedApp.listen((message) {
        handleMessage(message, 'background_clicked');
      });

      // 6. Terminated launch message
      final initialMessage = await getInitialMessage();
      if (initialMessage != null) {
        handleMessage(initialMessage, 'terminated_launch');
      }
    } catch (e, stack) {
      developer.log(
        'Error initializing NotificationService: $e',
        error: e,
        stackTrace: stack,
        name: 'NotificationService',
      );
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
  }
}
