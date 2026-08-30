import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment.dart';
import '../providers/supabase_client_provider.dart';
import '../utils/repository_exception.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Appointment>> fetchForUser(String userId) async {
    try {
      final res = await _client
          .from('appointments')
          .select()
          .eq('user_id', userId)
          .order('scheduled_for', ascending: true);
      final list = res as List;
      return list
          .map((row) => Appointment.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  Future<Appointment> create(
    String userId,
    String doctorId,
    DateTime scheduledFor,
  ) async {
    try {
      final res = await _client
          .from('appointments')
          .insert({
            'user_id': userId,
            'doctor_id': doctorId,
            'scheduled_for': scheduledFor.toUtc().toIso8601String(),
            'status': 'pending',
          })
          .select()
          .single();
      return Appointment.fromJson(res);
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  Future<void> cancel(String appointmentId) async {
    try {
      await _client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository(ref.read(supabaseClientProvider));
});
