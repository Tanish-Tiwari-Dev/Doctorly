import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/utils/availability_checker.dart';
import 'package:doctorly/utils/doctor_strings.dart';

void main() {
  group('AvailabilityChecker Unit Tests', () {
    // 2026-09-14 is a Monday
    final mondayMorning = DateTime(2026, 9, 14, 8, 30); // 8:30 AM
    final mondayMidday = DateTime(2026, 9, 14, 11, 00); // 11:00 AM
    final mondayEvening = DateTime(2026, 9, 14, 18, 00); // 6:00 PM
    // 2026-09-20 is a Sunday
    final sundayNoon = DateTime(2026, 9, 20, 12, 00);

    test('calculateDoctorAvailability returns byAppointmentOnly when opdByAppointment is true', () {
      final info = calculateDoctorAvailability(
        opdDays: ['Monday', 'Tuesday'],
        opdOpen: '10:00',
        opdClose: '13:00',
        opdByAppointment: true,
        currentTime: mondayMidday,
      );
      expect(info.status, equals(DoctorOpdStatus.byAppointmentOnly));
      expect(info.label, equals(DoctorStrings.byAppointmentOnly));
      expect(info.isOpen, isFalse);
    });

    test('calculateDoctorAvailability returns callToConfirm when days or times are missing/empty', () {
      final info1 = calculateDoctorAvailability(
        opdDays: [],
        opdOpen: '10:00',
        opdClose: '13:00',
        currentTime: mondayMidday,
      );
      expect(info1.status, equals(DoctorOpdStatus.callToConfirm));
      expect(info1.label, equals(DoctorStrings.callToConfirmOpd));
      expect(info1.label.contains('Unknown'), isFalse);

      final info2 = calculateDoctorAvailability(
        opdDays: ['Monday'],
        opdOpen: null,
        opdClose: null,
        currentTime: mondayMidday,
      );
      expect(info2.status, equals(DoctorOpdStatus.callToConfirm));
      expect(info2.label, equals(DoctorStrings.callToConfirmOpd));
    });

    test('calculateDoctorAvailability returns closedToday when today is not in opdDays', () {
      final info = calculateDoctorAvailability(
        opdDays: ['Monday', 'Tuesday', 'Wednesday'],
        opdOpen: '10:00',
        opdClose: '13:00',
        currentTime: sundayNoon, // Sunday
      );
      expect(info.status, equals(DoctorOpdStatus.closedToday));
      expect(info.label, equals(DoctorStrings.closedToday));
    });

    test('calculateDoctorAvailability returns openNow when current time is within hours', () {
      final info = calculateDoctorAvailability(
        opdDays: ['Monday', 'Wednesday', 'Friday'],
        opdOpen: '10:00',
        opdClose: '13:00',
        currentTime: mondayMidday, // Monday 11:00 AM
      );
      expect(info.status, equals(DoctorOpdStatus.openNow));
      expect(info.label, equals(DoctorStrings.openNow));
      expect(info.isOpen, isTrue);
    });

    test('calculateDoctorAvailability returns opensAt when current time is before opening hours', () {
      final info = calculateDoctorAvailability(
        opdDays: ['Monday', 'Wednesday', 'Friday'],
        opdOpen: '10:00',
        opdClose: '13:00',
        currentTime: mondayMorning, // Monday 8:30 AM
      );
      expect(info.status, equals(DoctorOpdStatus.opensAt));
      expect(info.label, equals('Opens at 10:00'));
      expect(info.nextOpenTime, equals('10:00'));
      expect(info.isOpen, isFalse);
    });

    test('calculateDoctorAvailability returns closedToday when current time is after closing hours', () {
      final info = calculateDoctorAvailability(
        opdDays: ['Monday', 'Wednesday', 'Friday'],
        opdOpen: '10:00',
        opdClose: '13:00',
        currentTime: mondayEvening, // Monday 6:00 PM
      );
      expect(info.status, equals(DoctorOpdStatus.closedToday));
      expect(info.label, equals(DoctorStrings.closedToday));
      expect(info.isOpen, isFalse);
    });

    // Backward compatibility tests for isDoctorOpen
    test('isDoctorOpen returns true for daytime shift when current time is within range', () {
      final now = DateTime(2026, 9, 1, 10, 30);
      final isOpen = isDoctorOpen('09:00', '17:00', now);
      expect(isOpen, isTrue);
    });

    test('isDoctorOpen returns false for daytime shift when current time is outside range', () {
      final morning = DateTime(2026, 9, 1, 8, 30);
      final evening = DateTime(2026, 9, 1, 18, 00);

      expect(isDoctorOpen('09:00', '17:00', morning), isFalse);
      expect(isDoctorOpen('09:00', '17:00', evening), isFalse);
    });

    test('isDoctorOpen handles overnight shifts correctly', () {
      final lateNight = DateTime(2026, 9, 1, 23, 15);
      final earlyMorning = DateTime(2026, 9, 1, 4, 30);
      final afternoon = DateTime(2026, 9, 1, 14, 0);

      expect(isDoctorOpen('22:00', '06:00', lateNight), isTrue);
      expect(isDoctorOpen('22:00', '06:00', earlyMorning), isTrue);
      expect(isDoctorOpen('22:00', '06:00', afternoon), isFalse);
    });
  });
}
