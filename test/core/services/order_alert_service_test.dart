import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/services/order_alert_service.dart';

class FakeAudioPlayer extends AudioPlayer {
  bool isPlaying = false;
  bool isStopped = false;
  ReleaseMode capturedReleaseMode = ReleaseMode.release;
  @override
  Source? source;

  @override
  ReleaseMode get releaseMode => capturedReleaseMode;

  @override
  Future<void> setAudioContext(AudioContext context) async {}

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    capturedReleaseMode = mode;
  }

  @override
  Future<void> play(
    Source src, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    source = src;
    isPlaying = true;
    isStopped = false;
  }

  @override
  Future<void> stop() async {
    isPlaying = false;
    isStopped = true;
  }

  @override
  Future<void> dispose() async {
    isPlaying = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channelNames = [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
      'vibration',
    ];
    for (final name in channelNames) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), (call) async {
        if (call.method == 'hasVibrator' || call.method == 'hasCustomVibrationsSupport') {
          return true;
        }
        return 1;
      });
    }
  });

  group('OrderAlertService Tests', () {
    late FakeAudioPlayer fakePlayer;
    late OrderAlertServiceImpl alertService;

    setUp(() {
      fakePlayer = FakeAudioPlayer();
      alertService = OrderAlertServiceImpl(audioPlayer: fakePlayer);
    });

    tearDown(() {
      alertService.dispose();
    });

    test('initial state is not alerting', () {
      expect(alertService.isAlerting, isFalse);
      expect(fakePlayer.isPlaying, isFalse);
    });

    test('startAlert sets isAlerting to true and plays audio on loop', () async {
      await alertService.startAlert();

      expect(alertService.isAlerting, isTrue);
      expect(fakePlayer.isPlaying, isTrue);
      expect(fakePlayer.capturedReleaseMode, ReleaseMode.loop);
      expect(fakePlayer.source, isA<AssetSource>());
      expect((fakePlayer.source as AssetSource).path, 'sounds/order-notification.mp3');
    });

    test('calling startAlert multiple times does not trigger duplicate audio', () async {
      await alertService.startAlert();
      await alertService.startAlert();

      expect(alertService.isAlerting, isTrue);
      expect(fakePlayer.isPlaying, isTrue);
    });

    test('stopAlert sets isAlerting to false and stops audio', () async {
      await alertService.startAlert();
      expect(alertService.isAlerting, isTrue);

      await alertService.stopAlert();

      expect(alertService.isAlerting, isFalse);
      expect(fakePlayer.isStopped, isTrue);
      expect(fakePlayer.isPlaying, isFalse);
    });

    test('stopAlert when not alerting is a safe no-op', () async {
      expect(alertService.isAlerting, isFalse);
      await alertService.stopAlert();
      expect(alertService.isAlerting, isFalse);
    });
  });
}
