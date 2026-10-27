import 'dart:async';

/// Global event bus for authentication events, such as 401 Unauthorized and 403 Account Blocked triggers.
class AuthEventBus {
  static final AuthEventBus _instance = AuthEventBus._internal();
  factory AuthEventBus() => _instance;
  AuthEventBus._internal();

  StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  StreamController<String?> _accountBlockedController =
      StreamController<String?>.broadcast();

  Stream<void> get onUnauthorized => _unauthorizedController.stream;
  Stream<String?> get onAccountBlocked => _accountBlockedController.stream;

  void emitUnauthorized() {
    if (_unauthorizedController.isClosed) {
      _unauthorizedController = StreamController<void>.broadcast();
    }
    _unauthorizedController.add(null);
  }

  void emitAccountBlocked([String? message]) {
    if (_accountBlockedController.isClosed) {
      _accountBlockedController = StreamController<String?>.broadcast();
    }
    _accountBlockedController.add(message);
  }

  void reset() {
    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.close();
    }
    if (!_accountBlockedController.isClosed) {
      _accountBlockedController.close();
    }
    _unauthorizedController = StreamController<void>.broadcast();
    _accountBlockedController = StreamController<String?>.broadcast();
  }

  void dispose() {
    reset();
  }
}
