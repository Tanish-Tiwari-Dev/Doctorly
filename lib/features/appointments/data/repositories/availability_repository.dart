import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository for querying doctor availability slots.
class AvailabilityRepository {
  /// Creates an [AvailabilityRepository] with the given [SupabaseClient].
  AvailabilityRepository(this._client);

  final SupabaseClient _client;

  /// Fetches available start times for a doctor up to [limit] where [is_booked] is false and [start_time] is in the future.
  Future<List<DateTime>> fetchSlots(
    String doctorId, {
    int limit = 50,
  }) async {
    try {
      final res = await _client
          .from('availability_slots')
          .select('start_time')
          .eq('doctor_id', doctorId)
          .eq('is_booked', false)
          .gt('start_time', DateTime.now().toUtc().toIso8601String())
          .order('start_time', ascending: true)
          .limit(limit);

      final list = res as List;
      return list
          .map((row) => DateTime.parse(row['start_time'] as String).toLocal())
          .toList();
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [AvailabilityRepository].
final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.read(supabaseClientProvider));
});
