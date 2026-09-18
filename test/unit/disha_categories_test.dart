import 'package:flutter_test/flutter_test.dart';
import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/utils/disha_categories.dart';

void main() {
  group('Disha Category Mapping Tests', () {
    test('contains all 8 patient-facing categories', () {
      expect(dishaCategories.length, equals(8));
      final slugs = dishaCategories.map((c) => c.slug).toList();
      expect(slugs, containsAll([
        'trauma',
        'brain_tumor',
        'spine',
        'stroke_neurovascular',
        'skull_base',
        'pediatric',
        'functional',
        'general',
      ]));
    });

    test('doctorMatchesCategory returns true when mapped service is "yes"', () {
      const doctor = Doctor(
        id: '1',
        name: 'Dr. Test Surgeon',
        specialty: 'Neurosurgery',
        distanceKm: 2.0,
        rating: 4.8,
        imageUrl: '',
        availability: 'Available Today',
        serviceStatuses: {
          'stroke': 'yes',
          'spine': 'no',
        },
      );

      expect(doctorMatchesCategory(doctor, 'stroke_neurovascular'), isTrue);
      expect(doctorMatchesCategory(doctor, 'spine'), isFalse);
    });

    test('doctorMatchesCategory matches multi-service category when any service is "yes"', () {
      const doctor = Doctor(
        id: '2',
        name: 'Dr. Spine Specialist',
        specialty: 'Neurosurgery',
        distanceKm: 3.0,
        rating: 4.9,
        imageUrl: '',
        availability: 'Available Today',
        serviceStatuses: {
          'spine': 'no',
          'minimally_invasive_spine': 'yes',
        },
      );

      expect(doctorMatchesCategory(doctor, 'spine'), isTrue);
    });

    test('doctorMatchesCategory returns false when service is "no" or "unknown"', () {
      const doctor = Doctor(
        id: '3',
        name: 'Dr. General',
        specialty: 'Neurosurgery',
        distanceKm: 1.0,
        rating: 4.5,
        imageUrl: '',
        availability: 'Available Today',
        serviceStatuses: {
          'trauma': 'unknown',
          'brain_tumor': 'no',
        },
      );

      expect(doctorMatchesCategory(doctor, 'trauma'), isFalse);
      expect(doctorMatchesCategory(doctor, 'brain_tumor'), isFalse);
    });

    test('doctorMatchesCategory matches general category if empty service list', () {
      const doctor = Doctor(
        id: '4',
        name: 'Dr. Any',
        specialty: 'Neurosurgery',
        distanceKm: 1.0,
        rating: 4.5,
        imageUrl: '',
        availability: 'Available Today',
      );

      expect(doctorMatchesCategory(doctor, 'general'), isTrue);
    });
  });
}
