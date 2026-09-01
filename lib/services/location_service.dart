import 'package:geolocator/geolocator.dart';

import 'package:doctorly/services/logger.dart';

/// Exception thrown during location checking or position acquisition.
class LocationException implements Exception {
  /// Creates a [LocationException] with a descriptive [message].
  const LocationException(this.message);

  /// Message describing the failure.
  final String message;

  @override
  String toString() => message;
}

/// Service handling GPS location permission requests and position fetching.
class LocationService {
  /// Checks permissions, requests them if necessary, and returns current [Position].
  /// Throws [LocationException] if location service is disabled or permission is denied.
  Future<Position> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LoggerService.instance.log.warning('Location services disabled on device');
      throw const LocationException(
        'Location services are disabled. Please enable GPS in device settings.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        LoggerService.instance.log.warning('Location permission denied by user');
        throw const LocationException('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LoggerService.instance.log.warning('Location permission permanently denied');
      throw const LocationException(
        'Location permissions are permanently denied. Please enable them in device settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to acquire location', e, st);
      throw LocationException('Failed to get current location: $e');
    }
  }

  /// Backward-compatible method returning null on error.
  Future<Position?> getCurrentPosition() async {
    try {
      return await getCurrentLocation();
    } catch (_) {
      return null;
    }
  }
}
