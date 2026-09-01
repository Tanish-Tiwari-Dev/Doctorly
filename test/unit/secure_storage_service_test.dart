import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:doctorly/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SecureStorageService Unit Tests', () {
    test('getString returns null when key does not exist', () async {
      final value = await SecureStorageService.instance.getString('non_existent');
      expect(value, isNull);
    });

    test('setString and getString write and read values correctly', () async {
      await SecureStorageService.instance.setString('test_key', 'secret_value');
      final value = await SecureStorageService.instance.getString('test_key');
      expect(value, equals('secret_value'));
    });

    test('delete removes specified key', () async {
      await SecureStorageService.instance.setString('key_to_delete', 'value');
      await SecureStorageService.instance.delete('key_to_delete');
      final value = await SecureStorageService.instance.getString('key_to_delete');
      expect(value, isNull);
    });

    test('deleteAll clears all values', () async {
      await SecureStorageService.instance.setString('k1', 'v1');
      await SecureStorageService.instance.setString('k2', 'v2');
      await SecureStorageService.instance.deleteAll();
      final v1 = await SecureStorageService.instance.getString('k1');
      final v2 = await SecureStorageService.instance.getString('k2');
      expect(v1, isNull);
      expect(v2, isNull);
    });
  });
}
