import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdHelper {
  static const String _kDeviceIdKey = 'delivery_app_device_id';

  /// Returns a stable, persistent device ID string across app launches.
  static Future<String> getDeviceId(SharedPreferences prefs) async {
    String? deviceId = prefs.getString(_kDeviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      final random = Random();
      final randomPart = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : 'device';
      deviceId = '$platform-$timestamp-$randomPart';
      await prefs.setString(_kDeviceIdKey, deviceId);
    }
    return deviceId;
  }
}
