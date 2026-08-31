import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/appointments/domain/models/appointment.dart';
import 'package:doctorly/features/auth/presentation/providers/auth_provider.dart';
import 'package:doctorly/features/appointments/data/repositories/appointments_repository.dart';
import 'package:doctorly/utils/error_localizer.dart';
import 'package:doctorly/utils/repository_exception.dart';

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

  Future<void> create(String doctorId, DateTime scheduledFor) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(StateError('Not signed in'), StackTrace.current);
      throw StateError('Not signed in');
    }
    final repo = ref.read(appointmentsRepositoryProvider);
    try {
      await repo.create(userId, doctorId, scheduledFor);
      ref.invalidateSelf();
    } on RepositoryException catch (e) {
      state = AsyncValue.error(localizeError(e), StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> cancel(String appointmentId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(StateError('Not signed in'), StackTrace.current);
      return;
    }
    final repo = ref.read(appointmentsRepositoryProvider);
    try {
      await repo.cancel(appointmentId);
      ref.invalidateSelf();
    } on RepositoryException catch (e) {
      state = AsyncValue.error(localizeError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
      AppointmentsNotifier.new,
    );
