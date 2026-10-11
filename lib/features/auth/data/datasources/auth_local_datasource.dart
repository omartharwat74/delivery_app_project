import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRegistrationToken(String token);
  Future<String?> getRegistrationToken();
  Future<void> clearRegistrationToken();
  Future<void> saveDriver(DriverModel driver);
  Future<DriverModel?> getDriver();
  Future<void> clearTokens();
  Future<void> clearSession();

  // Backward compatibility
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> saveRefreshToken(String token);
  Future<String> getRefreshToken();
  Future<void> saveDriverId(String driverId);
  Future<String> getDriverId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  static const String _keyDeliveryToken = 'delivery_token';
  static const String _keyRegistrationToken = 'delivery_registration_token';
  static const String _keyDriverProfile = 'driver_profile';
  static const String _keyLegacyToken = 'access_token';
  static const String _keyLegacyRefreshToken = 'refresh_token';
  static const String _keyDriverId = 'driver_id';

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _keyDeliveryToken, value: token);
    // Also save legacy key for backward compatibility
    await secureStorage.write(key: _keyLegacyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    final token = await secureStorage.read(key: _keyDeliveryToken);
    if (token != null && token.isNotEmpty) return token;
    return await secureStorage.read(key: _keyLegacyToken);
  }

  @override
  Future<void> saveRegistrationToken(String token) async {
    await secureStorage.write(key: _keyRegistrationToken, value: token);
  }

  @override
  Future<String?> getRegistrationToken() async {
    return await secureStorage.read(key: _keyRegistrationToken);
  }

  @override
  Future<void> clearRegistrationToken() async {
    await secureStorage.delete(key: _keyRegistrationToken);
  }

  @override
  Future<void> saveDriver(DriverModel driver) async {
    final jsonStr = jsonEncode(driver.toJson());
    await sharedPreferences.setString(_keyDriverProfile, jsonStr);
    await sharedPreferences.setString(_keyDriverId, driver.id.toString());
  }

  @override
  Future<DriverModel?> getDriver() async {
    final jsonStr = sharedPreferences.getString(_keyDriverProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DriverModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _keyDeliveryToken);
    await secureStorage.delete(key: _keyLegacyToken);
    await secureStorage.delete(key: _keyLegacyRefreshToken);
    await secureStorage.delete(key: _keyRegistrationToken);
  }

  @override
  Future<void> clearSession() async {
    await clearTokens();
    await sharedPreferences.remove(_keyDriverProfile);
    await sharedPreferences.remove(_keyDriverId);
  }

  // ---------------------------------------------------------------------------
  // Backward compatibility methods
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _keyLegacyRefreshToken, value: token);
  }

  @override
  Future<String> getRefreshToken() async {
    final token = await secureStorage.read(key: _keyLegacyRefreshToken);
    if (token != null) return token;
    return '';
  }

  @override
  Future<void> saveDriverId(String driverId) async {
    await sharedPreferences.setString(_keyDriverId, driverId);
  }

  @override
  Future<String> getDriverId() async {
    final driverId = sharedPreferences.getString(_keyDriverId);
    if (driverId != null) return driverId;
    return '';
  }
}
