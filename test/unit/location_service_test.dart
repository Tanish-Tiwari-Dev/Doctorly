import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/providers/location_provider.dart';
import 'package:doctorly/services/location_service.dart';

void main() {
  group('LocationService & LocationException Tests', () {
    test('LocationException returns correct toString message', () {
      const exception = LocationException('GPS disabled');
      expect(exception.toString(), 'GPS disabled');
      expect(exception.message, 'GPS disabled');
    });

    test('locationServiceProvider provides LocationService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(locationServiceProvider);
      expect(service, isA<LocationService>());
    });
  });
}
