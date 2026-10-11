import 'dart:async';

/// Global event bus for authentication events, such as 401 Unauthorized triggers.
class AuthEventBus {
  static final AuthEventBus _instance = AuthEventBus._internal();
  factory AuthEventBus() => _instance;
  AuthEventBus._internal();

  StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();

  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  void emitUnauthorized() {
    if (_unauthorizedController.isClosed) {
      _unauthorizedController = StreamController<void>.broadcast();
    }
    _unauthorizedController.add(null);
  }

  void reset() {
    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.close();
    }
    _unauthorizedController = StreamController<void>.broadcast();
  }

  void dispose() {
    reset();
  }
}
