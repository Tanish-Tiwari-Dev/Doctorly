import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import 'auth_provider.dart';
import 'doctor_provider.dart';

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return <Appointment>[];
    final client = ref.read(supabaseClientProvider);
    final res = await client
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .order('scheduled_for', ascending: true);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(Appointment.fromJson)
        .toList();
  }

  Future<void> create(String doctorId, DateTime scheduledFor) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(
        StateError('Not signed in'),
        StackTrace.current,
      );
      throw StateError('Not signed in');
    }
    final client = ref.read(supabaseClientProvider);
    try {
      await client.from('appointments').insert({
        'user_id': userId,
        'doctor_id': doctorId,
        'scheduled_for': scheduledFor.toUtc().toIso8601String(),
        'status': 'pending',
      });
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> cancel(String appointmentId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(
        StateError('Not signed in'),
        StackTrace.current,
      );
      return;
    }
    final client = ref.read(supabaseClientProvider);
    try {
      await client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId)
          .eq('user_id', userId);
      ref.invalidateSelf();
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
