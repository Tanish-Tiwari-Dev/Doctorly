import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/providers/notification_provider.dart';
import 'package:doctorly/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService & Provider Tests', () {
    test('notificationServiceProvider provides NotificationService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(notificationServiceProvider);
      expect(service, isA<NotificationService>());
      expect(service, equals(NotificationService.instance));
    });

    test('scheduleAppointmentReminder handles past dates gracefully without throwing', () async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2));

      expect(
        () async => NotificationService.instance.scheduleAppointmentReminder(
          id: 101,
          title: 'Test Reminder',
          body: 'Test Body',
          scheduledTime: pastDate,
        ),
        returnsNormally,
      );
    });

    test('cancelReminder completes without error', () async {
      expect(
        () async => NotificationService.instance.cancelReminder(101),
        returnsNormally,
      );
    });
  });
}
