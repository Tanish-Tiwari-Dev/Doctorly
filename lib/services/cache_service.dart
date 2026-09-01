import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:doctorly/services/logger.dart';

/// Singleton service wrapping Hive for local offline caching of application data.
class CacheService {
  CacheService._();

  static final CacheService instance = CacheService._();

  static const String doctorsBoxName = 'doctors_cache';
  static const String doctorsKey = 'cached_doctors_list';

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

  /// Caches a list of doctor objects represented as Maps.
  Future<void> cacheDoctors(List<Map<String, dynamic>> doctors) async {
    if (!_isInitialized) await initialize();
    try {
      final box = await Hive.openBox<String>(doctorsBoxName);
      final jsonString = jsonEncode(doctors);
      await box.put(doctorsKey, jsonString);
      LoggerService.instance.log.info('Cached ${doctors.length} doctors in Hive');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to cache doctors in Hive', e, st);
    }
  }

  /// Retrieves the cached doctor listings, or `null` if no cache exists.
  Future<List<Map<String, dynamic>>?> getCachedDoctors() async {
    if (!_isInitialized) await initialize();
    try {
      final box = await Hive.openBox<String>(doctorsBoxName);
      final jsonString = box.get(doctorsKey);
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
      final box = await Hive.openBox<String>(doctorsBoxName);
      await box.clear();
      LoggerService.instance.log.info('Cleared doctor cache');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to clear doctor cache', e, st);
    }
  }
}
