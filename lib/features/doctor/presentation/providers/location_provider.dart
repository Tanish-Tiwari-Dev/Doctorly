import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/services/location_service.dart';

/// Provider for accessing the singleton [LocationService] instance.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
