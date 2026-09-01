import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:doctorly/services/logger.dart';

/// Singleton service wrapping [FlutterSecureStorage] for encrypted key-value storage.
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  /// Saves a string [value] associated with [key].
  Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      LoggerService.instance.log.severe('SecureStorage setString failed for key: $key', e, st);
    }
  }

  /// Retrieves the string value associated with [key], or `null` if not found.
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      LoggerService.instance.log.severe('SecureStorage getString failed for key: $key', e, st);
      return null;
    }
  }

  /// Deletes the value associated with [key].
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      LoggerService.instance.log.severe('SecureStorage delete failed for key: $key', e, st);
    }
  }

  /// Deletes all keys and values from secure storage.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      LoggerService.instance.log.severe('SecureStorage deleteAll failed', e, st);
    }
  }
}
