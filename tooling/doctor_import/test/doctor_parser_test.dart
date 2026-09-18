import 'dart:io';

import 'package:test/test.dart';

import '../lib/doctor_parser.dart';

void main() {
  group('DoctorParser Unit Tests', () {
    test('normalizePhone handles various Indian phone formats to E.164 and preserves placeholders', () {
      expect(DoctorParser.normalizePhone('9876543210'), equals('+919876543210'));
      expect(DoctorParser.normalizePhone('09876543210'), equals('+919876543210'));
      expect(DoctorParser.normalizePhone('+919876543210'), equals('+919876543210'));
      expect(DoctorParser.normalizePhone('+91 98765 43210'), equals('+919876543210'));
      expect(DoctorParser.normalizePhone('(098) 76543210'), equals('+919876543210'));
      expect(DoctorParser.normalizePhone('8887776665'), equals('+918887776665'));
      expect(DoctorParser.normalizePhone('7123456789'), equals('+917123456789'));
      expect(DoctorParser.normalizePhone('6123456789'), equals('+916123456789'));
      // Placeholder test numbers preserved safely without throwing
      expect(DoctorParser.normalizePhone('0000000001'), equals('+910000000001'));
      expect(DoctorParser.normalizePhone('0000000030'), equals('+910000000030'));
    });

    test('normalizePhone rejects invalid phone numbers', () {
      expect(DoctorParser.normalizePhone('12345'), isNull);
      expect(DoctorParser.normalizePhone('abcd'), isNull);
      expect(DoctorParser.normalizePhone(null), isNull);
      expect(DoctorParser.normalizePhone(''), isNull);
    });

    test('parseLanguages splits on commas, semicolons, or slashes and trims', () {
      final langs = DoctorParser.parseLanguages('English, Hindi, Gujarati; Marathi / Punjabi');
      expect(langs, equals(['English', 'Hindi', 'Gujarati', 'Marathi', 'Punjabi']));
      expect(DoctorParser.parseLanguages(''), isEmpty);
      expect(DoctorParser.parseLanguages(null), isEmpty);
    });

    test('parseOpdDays parses standard schedule expressions', () {
      expect(
        DoctorParser.parseOpdDays('Daily'),
        equals(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']),
      );
      expect(
        DoctorParser.parseOpdDays('Mon-Sat'),
        equals(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']),
      );
      expect(
        DoctorParser.parseOpdDays('Mon/Wed/Fri'),
        equals(['Monday', 'Wednesday', 'Friday']),
      );
      expect(
        DoctorParser.parseOpdDays('Tue/Thu/Sat'),
        equals(['Tuesday', 'Thursday', 'Saturday']),
      );
    });

    test('parseOpdTiming handles standard time ranges and By Appointment', () {
      final t1 = DoctorParser.parseOpdTiming('10:00 AM-1:00 PM');
      expect(t1.open, equals('10:00'));
      expect(t1.close, equals('13:00'));
      expect(t1.byAppointment, isFalse);

      final t2 = DoctorParser.parseOpdTiming('09:00 AM-12:00 PM');
      expect(t2.open, equals('09:00'));
      expect(t2.close, equals('12:00'));
      expect(t2.byAppointment, isFalse);

      final t3 = DoctorParser.parseOpdTiming('By appointment');
      expect(t3.byAppointment, isTrue);
      expect(t3.open, isNull);

      final t4 = DoctorParser.parseOpdTiming('Appointment only');
      expect(t4.byAppointment, isTrue);
    });

    test('validateCoordinates validates lat 20-25 and lon 68-75 bounds', () {
      // Valid coordinates inside Gujarat / Western India
      final valid = DoctorParser.validateCoordinates('23.0225', '72.5714');
      expect(valid.lat, equals(23.0225));
      expect(valid.lon, equals(72.5714));

      // Latitude out of range
      final invalidLat = DoctorParser.validateCoordinates('28.6139', '72.5714');
      expect(invalidLat.lat, isNull);
      expect(invalidLat.lon, isNull);

      // Longitude out of range
      final invalidLon = DoctorParser.validateCoordinates('23.0225', '77.2090');
      expect(invalidLon.lat, isNull);
      expect(invalidLon.lon, isNull);
    });

    test('mapFlag standardizes flags to yes, no, or unknown', () {
      expect(DoctorParser.mapFlag('yes'), equals('yes'));
      expect(DoctorParser.mapFlag('Y'), equals('yes'));
      expect(DoctorParser.mapFlag('True'), equals('yes'));
      expect(DoctorParser.mapFlag('no'), equals('no'));
      expect(DoctorParser.mapFlag('N'), equals('no'));
      expect(DoctorParser.mapFlag('False'), equals('no'));
      expect(DoctorParser.mapFlag(''), equals('unknown'));
      expect(DoctorParser.mapFlag(null), equals('unknown'));
    });

    test('parseTsv round-trip on first record (TEST-DR-001), TEST-DR-030 (exp resets to 2), and final record (TEST-DR-100)', () {
      final file = File(File('docs/data/doctorly_neuro_test_data.tsv').existsSync() ? 'docs/data/doctorly_neuro_test_data.tsv' : '../../docs/data/doctorly_neuro_test_data.tsv');
      final content = file.readAsStringSync();
      final records = DoctorParser.parseTsv(content, defaultDataStatus: 'published');

      expect(records.length, equals(100));

      // 1. First record: TEST-DR-001
      final r1 = records.firstWhere((r) => r.externalId == 'TEST-DR-001');
      expect(r1.fullName, equals('Dr Aarav Sharma (Test 001)'));
      expect(r1.district, equals('Ahmedabad'));
      expect(r1.yearsOfExperience, equals(2));
      expect(r1.mobile, equals('+910000000001'));
      expect(r1.latitude, equals(23.0185));
      expect(r1.longitude, equals(72.5654));
      expect(r1.opdDays, equals(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']));
      expect(r1.servicesMap['trauma'], equals('yes'));
      expect(r1.servicesMap['spine'], equals('unknown'));

      // 2. TEST-DR-030: Years of experience resets to 2
      final r30 = records.firstWhere((r) => r.externalId == 'TEST-DR-030');
      expect(r30.fullName, equals('Dr Rudra Patel (Test 030)'));
      expect(r30.district, equals('Kutch'));
      expect(r30.yearsOfExperience, equals(2));
      expect(r30.mobile, equals('+910000000030'));
      expect(r30.latitude, equals(23.2459));
      expect(r30.longitude, equals(69.6629));
      expect(r30.opdByAppointment, isTrue);
      expect(r30.servicesMap['brain_tumor'], equals('yes'));
      expect(r30.servicesMap['trauma'], equals('unknown'));

      // 3. Final record: TEST-DR-100
      final r100 = records.firstWhere((r) => r.externalId == 'TEST-DR-100');
      expect(r100.fullName, equals('Dr Tara Joshi (Test 100)'));
      expect(r100.district, equals('Amreli'));
      expect(r100.yearsOfExperience, equals(14));
      expect(r100.mobile, equals('+910000000100'));
      expect(r100.latitude, equals(21.6072));
      expect(r100.longitude, equals(71.2181));
      expect(r100.servicesMap['trauma'], equals('yes'));
      expect(r100.servicesMap['spine'], equals('unknown'));
    });
  });
}
