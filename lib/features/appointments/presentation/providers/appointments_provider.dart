import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/appointments/data/repositories/appointments_repository.dart';
import 'package:doctorly/features/appointments/domain/models/appointment.dart';
import 'package:doctorly/features/auth/presentation/providers/auth_provider.dart';
import 'package:doctorly/features/appointments/presentation/providers/notification_provider.dart';
import 'package:doctorly/utils/error_localizer.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// AsyncNotifier managing the user's list of booked appointments.
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return <Appointment>[];
    final repo = ref.read(appointmentsRepositoryProvider);
    try {
      return await repo.fetchForUser(userId);
    } on RepositoryException catch (e) {
      throw AsyncError(localizeError(e), StackTrace.current);
    }
  }

  /// Creates a new appointment with [doctorId] at [scheduledFor] and schedules a local notification.
  Future<void> create(String doctorId, DateTime scheduledFor) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(StateError('Not signed in'), StackTrace.current);
      throw StateError('Not signed in');
    }
    final repo = ref.read(appointmentsRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    try {
      final appointment = await repo.create(userId, doctorId, scheduledFor);
      final notificationId = appointment.id.hashCode & 0x7FFFFFFF;
      await notificationService.scheduleAppointmentReminder(
        id: notificationId,
        title: 'Upcoming Appointment Reminder',
        body: 'You have an appointment scheduled in 1 hour.',
        scheduledTime: appointment.scheduledFor,
      );
      ref.invalidateSelf();
    } on RepositoryException catch (e) {
      state = AsyncValue.error(localizeError(e), StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Cancels the appointment [appointmentId] and cancels the associated local notification.
  Future<void> cancel(String appointmentId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(StateError('Not signed in'), StackTrace.current);
      return;
    }
    final repo = ref.read(appointmentsRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    try {
      await repo.cancel(appointmentId);
      final notificationId = appointmentId.hashCode & 0x7FFFFFFF;
      await notificationService.cancelReminder(notificationId);
      ref.invalidateSelf();
    } on RepositoryException catch (e) {
      state = AsyncValue.error(localizeError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider managing appointments list state and actions.
final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
      AppointmentsNotifier.new,
    );
