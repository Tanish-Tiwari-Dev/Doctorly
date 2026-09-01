import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:doctorly/services/logger.dart';

/// Singleton service handling local appointment notifications and reminders.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes the local notification plugin and timezones.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(initSettings);

      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();

      _isInitialized = true;
      LoggerService.instance.log.info('NotificationService initialized');
    } catch (e, st) {
      LoggerService.instance.log.severe('NotificationService initialization failed', e, st);
    }
  }

  /// Schedules an appointment reminder notification 1 hour before [scheduledTime].
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_isInitialized) await initialize();

    final reminderTime = scheduledTime.subtract(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) {
      LoggerService.instance.log.info('Reminder time $reminderTime is in the past; skipping notification.');
      return;
    }

    try {
      final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'appointment_reminders',
        'Appointment Reminders',
        channelDescription: 'Notifications for upcoming doctor appointments',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzReminderTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      LoggerService.instance.log.info('Scheduled appointment reminder #$id for $tzReminderTime');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to schedule reminder #$id', e, st);
    }
  }

  /// Cancels a scheduled appointment notification by [id].
  Future<void> cancelReminder(int id) async {
    if (!_isInitialized) await initialize();
    try {
      await _plugin.cancel(id);
      LoggerService.instance.log.info('Cancelled notification reminder #$id');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to cancel reminder #$id', e, st);
    }
  }
}
