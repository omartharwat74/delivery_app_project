import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  /// Checks and requests location permissions from the user.
  Future<bool> checkAndRequestPermission();

  /// Retrieves the current position of the device.
  /// Falls back to the last known position if unavailable or denied.
  Future<Position?> getCurrentPosition();

  /// Retrieves the last known position of the device.
  Future<Position?> getLastKnownPosition();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> checkAndRequestPermission() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        developer.log('Location services are disabled on the device.', name: 'LocationService');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permission was denied by the user.', name: 'LocationService');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permission is permanently denied.', name: 'LocationService');
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e, stack) {
      developer.log(
        'Error checking/requesting location permissions: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationService',
      );
      return false;
    }
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
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
        'Error getting current position: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationService',
      );
      return await getLastKnownPosition();
    }
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      developer.log('Error getting last known position: $e', name: 'LocationService');
      return null;
    }
  }
}
