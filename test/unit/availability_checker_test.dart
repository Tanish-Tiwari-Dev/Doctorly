import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/utils/availability_checker.dart';

void main() {
  group('AvailabilityChecker Unit Tests', () {
    test('isDoctorOpen returns true for daytime shift when current time is within range', () {
      final now = DateTime(2026, 9, 1, 10, 30); // 10:30 AM
      final isOpen = isDoctorOpen('09:00', '17:00', now);
      expect(isOpen, isTrue);
    });

    test('isDoctorOpen returns false for daytime shift when current time is outside range', () {
      final morning = DateTime(2026, 9, 1, 8, 30); // 8:30 AM
      final evening = DateTime(2026, 9, 1, 18, 00); // 6:00 PM

      expect(isDoctorOpen('09:00', '17:00', morning), isFalse);
      expect(isDoctorOpen('09:00', '17:00', evening), isFalse);
    });

    test('isDoctorOpen returns true at exact opening time and false at closing time', () {
      final exactOpen = DateTime(2026, 9, 1, 9, 00);
      final exactClose = DateTime(2026, 9, 1, 17, 00);

      expect(isDoctorOpen('09:00', '17:00', exactOpen), isTrue);
      expect(isDoctorOpen('09:00', '17:00', exactClose), isFalse);
    });

    test('isDoctorOpen handles overnight shifts correctly', () {
      final lateNight = DateTime(2026, 9, 1, 23, 15); // 11:15 PM
      final earlyMorning = DateTime(2026, 9, 1, 4, 30); // 4:30 AM
      final afternoon = DateTime(2026, 9, 1, 14, 0); // 2:00 PM

      expect(isDoctorOpen('22:00', '06:00', lateNight), isTrue);
      expect(isDoctorOpen('22:00', '06:00', earlyMorning), isTrue);
      expect(isDoctorOpen('22:00', '06:00', afternoon), isFalse);
    });

    test('isDoctorOpen handles null and invalid inputs gracefully', () {
      final now = DateTime(2026, 9, 1, 12, 0);
      expect(isDoctorOpen(null, null, now), isTrue);
      expect(isDoctorOpen('invalid', 'invalid', now), isTrue);
    });
  });
}
