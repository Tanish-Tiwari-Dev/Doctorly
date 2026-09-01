import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository for managing user's favorite doctors in Supabase.
class FavoritesRepository {
  /// Creates a [FavoritesRepository] with the given [SupabaseClient].
  FavoritesRepository(this._client);

  final SupabaseClient _client;

  /// Fetches favorite doctor IDs for the specified [userId].
  Future<Set<String>> fetchForUser(String userId) async {
    try {
      final res = await _client
          .from('favorites')
          .select('doctor_id')
          .eq('user_id', userId);
      final ids = (res as List)
          .cast<Map<String, dynamic>>()
          .map((row) => row['doctor_id'] as String)
          .toSet();
      return ids;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Adds [doctorId] to the favorite list for [userId].
  Future<void> add(String userId, String doctorId) async {
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'doctor_id': doctorId,
      });
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Removes [doctorId] from the favorite list for [userId].
  Future<void> remove(String userId, String doctorId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [FavoritesRepository].
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.read(supabaseClientProvider));
});
