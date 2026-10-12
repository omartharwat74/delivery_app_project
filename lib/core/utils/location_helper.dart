import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

/// Helper utility for handling device location and permissions cleanly.
class LocationHelper {
  LocationHelper._();

  /// Requests location permissions from the user and verifies that location services are enabled.
  /// Returns `true` if permission is granted (`whileInUse` or `always`), otherwise `false`.
  static Future<bool> requestLocationPermission() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        developer.log('Location services are disabled on device.', name: 'LocationHelper');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permission denied by user.', name: 'LocationHelper');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permission permanently denied.', name: 'LocationHelper');
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e, stack) {
      developer.log(
        'Error requesting location permission: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationHelper',
      );
      return false;
    }
  }

  /// Retrieves the current device position.
  /// If permission is denied or location is unavailable, falls back to the last known position.
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return await getLastKnownPosition();
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e, stack) {
      developer.log(
        'Error retrieving current position: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationHelper',
      );
      return await getLastKnownPosition();
    }
  }

  /// Retrieves the last known position of the device.
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      developer.log('Error getting last known position: $e', name: 'LocationHelper');
      return null;
    }
  }
}
