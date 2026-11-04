import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

abstract class OrderAlertService {
  bool get isAlerting;
  Future<void> startAlert();
  Future<void> stopAlert();
  void dispose();
}

class OrderAlertServiceImpl implements OrderAlertService {
  final AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  Timer? _vibrationTimer;

  OrderAlertServiceImpl({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initAudioContext();
  }

  Future<void> _initAudioContext() async {
    try {
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransientExclusive,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ [OrderAlertService] Error setting AudioContext: $e');
    }
  }

  @override
  bool get isAlerting => _isAlerting;

  @override
  Future<void> startAlert() async {
    if (_isAlerting) return;
    _isAlerting = true;
    debugPrint('🚨 [OrderAlertService] Starting order alert sound & vibration');

    // 1. Play audio looping
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/order-notification.mp3'));
    } catch (e) {
      debugPrint('⚠️ [OrderAlertService] Error playing audio: $e');
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }

    // 2. Trigger vibration pattern
    _startVibration();
  }

  void _startVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        final hasCustom = await Vibration.hasCustomVibrationsSupport();
        if (hasCustom == true) {
          await Vibration.vibrate(
            pattern: [0, 800, 400, 800],
            repeat: 0,
          );
          return;
        }
      }
    } catch (_) {}

    // Fallback: periodic vibration timer for devices with basic vibrator or iOS haptics
    _vibrationTimer?.cancel();
    _triggerSingleVibration();
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!_isAlerting) {
        _vibrationTimer?.cancel();
        return;
      }
      _triggerSingleVibration();
    });
  }

  void _triggerSingleVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 800);
        return;
      }
    } catch (_) {}

    try {
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  @override
  Future<void> stopAlert() async {
    if (!_isAlerting) return;
    _isAlerting = false;
    debugPrint('🛑 [OrderAlertService] Stopping order alert sound & vibration');

    _vibrationTimer?.cancel();
    _vibrationTimer = null;

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('⚠️ [OrderAlertService] Error stopping audio: $e');
    }

    try {
      await Vibration.cancel();
    } catch (e) {
      debugPrint('⚠️ [OrderAlertService] Error cancelling vibration: $e');
    }
  }

  @override
  void dispose() {
    stopAlert();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
  }
}
