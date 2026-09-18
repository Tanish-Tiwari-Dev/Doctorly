import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/features/doctor/data/repositories/doctors_repository.dart';
import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/services/cache_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}

class MockTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder<List<Map<String, dynamic>>> mockFilterBuilder;
  late MockTransformBuilder<List<Map<String, dynamic>>> mockTransformBuilder;
  late DoctorsRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_cache_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockFilterBuilder<List<Map<String, dynamic>>>();
    mockTransformBuilder = MockTransformBuilder<List<Map<String, dynamic>>>();
    repository = DoctorsRepository(mockClient);

    // Ensure cache box is clean before each test
    final box = await Hive.openBox<dynamic>(CacheService.doctorsBoxName);
    await box.clear();
  });

  group('CacheService Schema Versioning & Fallback Tests', () {
    test('Doctor.fromJson safely parses empty and legacy JSON without throwing', () {
      // Completely empty JSON
      final emptyDoctor = Doctor.fromJson({});
      expect(emptyDoctor.id, isEmpty);
      expect(emptyDoctor.name, isEmpty);
      expect(emptyDoctor.specialty, isEmpty);
      expect(emptyDoctor.rating, 0.0);
      expect(emptyDoctor.district, isNull);
      expect(emptyDoctor.opdDays, isEmpty);
      expect(emptyDoctor.serviceStatuses, isEmpty);
      expect(emptyDoctor.teleconsultation, isFalse);
      expect(emptyDoctor.emergency24x7, 'unknown');

      // Legacy pre-Disha JSON shape (missing all new columns)
      final legacyJson = {
        'id': 'legacy-doc-1',
        'name': 'Dr. Old Specialist',
        'specialty': 'Neurology',
        'rating': 4.6,
        'image_url': 'https://example.com/doc.jpg',
        'availability': 'Available Today',
        'address': '123 Old Road',
      };
      final legacyDoctor = Doctor.fromJson(legacyJson);
      expect(legacyDoctor.id, 'legacy-doc-1');
      expect(legacyDoctor.name, 'Dr. Old Specialist');
      expect(legacyDoctor.specialty, 'Neurology');
      expect(legacyDoctor.rating, 4.6);
      expect(legacyDoctor.district, isNull);
      expect(legacyDoctor.subSpecialty, isNull);
      expect(legacyDoctor.qualification, isNull);
      expect(legacyDoctor.opdDays, isEmpty);
      expect(legacyDoctor.serviceStatuses, isEmpty);
      expect(legacyDoctor.isAvailableToday, isTrue);
    });

    test(
        'legacy cache without version or mismatched version clears box, treats cache as cold, and fetchAll repopulates correctly',
        () async {
      final box = await Hive.openBox<dynamic>(CacheService.doctorsBoxName);

      // 1. Write legacy data without version stamp into Hive box
      final legacyDocJson = {
        'id': 'stale-doc-1',
        'name': 'Dr. Stale Record',
        'specialty': 'General Medicine',
        'rating': 4.0,
      };
      await box.put(CacheService.doctorsKey, jsonEncode([legacyDocJson]));
      // Note: no version key placed in box, simulating pre-versioned cache

      // Verify that getCachedDoctors returns null and clears the stale cache
      final coldCached = await CacheService.instance.getCachedDoctors();
      expect(coldCached, isNull);
      expect(box.get(CacheService.doctorsKey), isNull);

      // 2. Setup mock for fresh database fetch
      final freshDocJson = {
        'id': 'fresh-doc-1',
        'name': 'Dr. Fresh Specialist',
        'specialty': 'Neurosurgery',
        'rating': 4.9,
        'district': 'Ahmedabad',
        'opd_days': ['Monday', 'Tuesday'],
        'doctor_services': [
          {
            'status': 'yes',
            'services': {'slug': 'trauma', 'name': 'Head Injury & Trauma'}
          }
        ],
      };

      when(() => mockClient.from('doctors')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select('*, doctor_services(status, services(slug, name))'))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order('rating', ascending: false))
          .thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.then<dynamic>(
            any(),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as dynamic;
        return Future<dynamic>.value(callback([freshDocJson]));
      });

      // Call fetchAll on repository
      final freshDoctors = await repository.fetchAll();
      expect(freshDoctors.length, 1);
      expect(freshDoctors.first.id, 'fresh-doc-1');
      expect(freshDoctors.first.district, 'Ahmedabad');
      expect(freshDoctors.first.serviceStatuses['trauma'], 'yes');

      // 3. Verify CacheService is now populated with new schema version and fresh doctor record
      expect(box.get(CacheService.cacheVersionKey), CacheService.cacheSchemaVersion);
      final reloadedCache = await CacheService.instance.getCachedDoctors();
      expect(reloadedCache, isNotNull);
      expect(reloadedCache!.length, 1);
      expect(reloadedCache.first['id'], 'fresh-doc-1');
    });

    test('mismatched cache version clears box and returns null', () async {
      final box = await Hive.openBox<dynamic>(CacheService.doctorsBoxName);

      // Write data stamped with older version (e.g. 1)
      await box.put(CacheService.cacheVersionKey, 1);
      await box.put(
        CacheService.doctorsKey,
        jsonEncode([{'id': 'v1-doc', 'name': 'V1'}]),
      );

      final result = await CacheService.instance.getCachedDoctors();
      expect(result, isNull);
      expect(box.isEmpty, isTrue);
    });
  });
}
