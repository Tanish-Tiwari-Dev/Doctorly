import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:doctorly/services/logger.dart';

/// Singleton service wrapping Hive for local offline caching of application data.
class CacheService {
  CacheService._();

  static final CacheService instance = CacheService._();

  static const String doctorsBoxName = 'doctors_cache';
  static const String doctorsKey = 'cached_doctors_list';
  static const String cacheVersionKey = 'cache_schema_version';

  /// Current schema version for doctor cache. Increment when doctor model or schema changes.
  // ignore: constant_identifier_names
  static const int CACHE_SCHEMA_VERSION = 3;
  static const int cacheSchemaVersion = CACHE_SCHEMA_VERSION;

  bool _isInitialized = false;

  /// Initializes Hive for Flutter applications.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      _isInitialized = true;
      LoggerService.instance.log.info('CacheService initialized');
    } catch (e, st) {
      LoggerService.instance.log.severe('CacheService initialization failed', e, st);
    }
  }

  /// Caches a list of doctor objects represented as Maps stamped with current schema version.
  Future<void> cacheDoctors(List<Map<String, dynamic>> doctors) async {
    if (!_isInitialized) await initialize();
    try {
      final box = await Hive.openBox<dynamic>(doctorsBoxName);
      final jsonString = jsonEncode(doctors);
      await box.put(doctorsKey, jsonString);
      await box.put(cacheVersionKey, cacheSchemaVersion);
      LoggerService.instance.log.info('Cached ${doctors.length} doctors in Hive (v$cacheSchemaVersion)');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to cache doctors in Hive', e, st);
    }
  }

  /// Retrieves the cached doctor listings, or `null` if no cache exists or version is mismatched.
  Future<List<Map<String, dynamic>>?> getCachedDoctors() async {
    if (!_isInitialized) await initialize();
    try {
      final box = await Hive.openBox<dynamic>(doctorsBoxName);

      final version = box.get(cacheVersionKey);
      if (version == null || version != cacheSchemaVersion) {
        LoggerService.instance.log.warning(
          'Cache schema version mismatch or absent (found: $version, expected: $cacheSchemaVersion). Clearing cache.',
        );
        await box.clear();
        return null;
      }

      final dynamic raw = box.get(doctorsKey);
      final jsonString = raw is String ? raw : null;
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to read cached doctors from Hive', e, st);
      return null;
    }
  }

  /// Clears the doctor listings cache.
  Future<void> clearCache() async {
    if (!_isInitialized) await initialize();
    try {
      final box = await Hive.openBox<dynamic>(doctorsBoxName);
      await box.clear();
      LoggerService.instance.log.info('Cleared doctor cache');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to clear doctor cache', e, st);
    }
  }
}
