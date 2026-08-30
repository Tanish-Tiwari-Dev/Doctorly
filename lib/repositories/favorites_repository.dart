import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_client_provider.dart';
import '../utils/repository_exception.dart';

class FavoritesRepository {
  FavoritesRepository(this._client);

  final SupabaseClient _client;

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
      throw RepositoryException(
        RepositoryExceptionKind.unknown,
        e.toString(),
      );
    }
  }

  Future<void> add(String userId, String doctorId) async {
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'doctor_id': doctorId,
      });
    } catch (e) {
      throw RepositoryException(
        RepositoryExceptionKind.unknown,
        e.toString(),
      );
    }
  }

  Future<void> remove(String userId, String doctorId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId);
    } catch (e) {
      throw RepositoryException(
        RepositoryExceptionKind.unknown,
        e.toString(),
      );
    }
  }
}

final favoritesRepositoryProvider =
    Provider<FavoritesRepository>((ref) {
      return FavoritesRepository(ref.read(supabaseClientProvider));
    });
