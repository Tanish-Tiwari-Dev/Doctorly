import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';

void main() {
  group('DoctorFilter Unit Tests', () {
    test('default DoctorFilter is initialized with expected default values', () {
      const filter = DoctorFilter();
      expect(filter.minRating, 0.0);
      expect(filter.maxDistanceKm, 50);
      expect(filter.specialty, isNull);
      expect(filter.isDefault, isTrue);
    });

    test('copyWith updates fields correctly and clearSpecialty clears specialty', () {
      const filter = DoctorFilter();
      final updated = filter.copyWith(
        minRating: 4.5,
        maxDistanceKm: 15,
        specialty: 'Cardiologist',
      );

      expect(updated.minRating, 4.5);
      expect(updated.maxDistanceKm, 15);
      expect(updated.specialty, 'Cardiologist');
      expect(updated.isDefault, isFalse);

      final cleared = updated.copyWith(clearSpecialty: true);
      expect(cleared.specialty, isNull);
    });

    test('DoctorFilterNotifier updates state and resets correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(doctorFilterProvider.notifier);
      expect(container.read(doctorFilterProvider).isDefault, isTrue);

      notifier.setMinRating(4.0);
      expect(container.read(doctorFilterProvider).minRating, 4.0);

      notifier.setMaxDistanceKm(20);
      expect(container.read(doctorFilterProvider).maxDistanceKm, 20);

      notifier.setSpecialty('Dentist');
      expect(container.read(doctorFilterProvider).specialty, 'Dentist');

      notifier.setOpenNowOnly(true);
      expect(container.read(doctorFilterProvider).openNowOnly, isTrue);
      expect(container.read(doctorFilterProvider).isDefault, isFalse);

      notifier.reset();
      expect(container.read(doctorFilterProvider).isDefault, isTrue);
      expect(container.read(doctorFilterProvider).openNowOnly, isFalse);
    });
  });
}
