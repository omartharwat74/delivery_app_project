import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  serviceDisabled,
  denied,
  deniedForever,
  granted,
}

abstract class LocationService {
  /// Checks and requests location permissions from the user.
  Future<bool> checkAndRequestPermission();

  /// Retrieves the current permission status without prompting.
  Future<LocationPermissionStatus> getPermissionStatus();

  /// Requests location permissions explicitly with detailed status return.
  Future<LocationPermissionStatus> requestPermission();

  /// Retrieves the current position of the device.
  /// Falls back to the last known position if unavailable or denied.
  Future<Position?> getCurrentPosition();

  /// Retrieves the last known position of the device.
  Future<Position?> getLastKnownPosition();

  /// Provides a stream of device position updates.
  Stream<Position> getPositionStream({LocationSettings? locationSettings});

  /// Opens the device settings page for this app.
  Future<bool> openAppSettings();

  /// Opens the device location service settings page.
  Future<bool> openLocationSettings();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationPermissionStatus> getPermissionStatus() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        developer.log('Location services are disabled on device.', name: 'LocationService');
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();
      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return LocationPermissionStatus.granted;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.denied;
      }
    } catch (e, stack) {
      developer.log(
        'Error checking permission status: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationService',
      );
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        developer.log('Location services are disabled on device.', name: 'LocationService');
        return LocationPermissionStatus.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.denied:
          developer.log('Location permission was denied by user.', name: 'LocationService');
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          developer.log('Location permission is permanently denied.', name: 'LocationService');
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return LocationPermissionStatus.granted;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.denied;
      }
    } catch (e, stack) {
      developer.log(
        'Error requesting permission: $e',
        error: e,
        stackTrace: stack,
        name: 'LocationService',
      );
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<bool> checkAndRequestPermission() async {
    final status = await requestPermission();
    return status == LocationPermissionStatus.granted;
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

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ??
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
    );
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      developer.log('Error opening app settings: $e', name: 'LocationService');
      return false;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      developer.log('Error opening location settings: $e', name: 'LocationService');
      return false;
    }
  }
}
