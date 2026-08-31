import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/doctor.dart';
import '../providers/supabase_client_provider.dart';
import '../utils/repository_exception.dart';

class DoctorsRepository {
  DoctorsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Doctor>> fetchAll({String orderBy = 'rating'}) async {
    try {
      final res = await _client
          .from('doctors')
          .select()
          .order(orderBy, ascending: false);
      final list = res as List;
      return list
          .map((row) => Doctor.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  Future<Doctor?> fetchById(String id) async {
    try {
      final res = await _client
          .from('doctors')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (res == null) return null;
      return Doctor.fromJson(res);
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches doctors near the specified [lat] and [lng] coordinates within [radiusKm].
  Future<List<Doctor>> fetchNearby(
    double lat,
    double lng, {
    double radiusKm = 5,
    int limit = 20,
  }) async {
    try {
      final res = await _client.rpc(
        'nearby_doctors',
        params: {'lat': lat, 'lng': lng, 'radius_km': radiusKm},
      );
      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map((row) => Doctor.fromJson(row))
          .toList();
      if (list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  Future<List<Doctor>> fetchTopRated({int limit = 6}) async {
    try {
      final res = await _client
          .from('doctors')
          .select()
          .order('rating', ascending: false)
          .limit(limit);
      final list = res as List;
      return list
          .map((row) => Doctor.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

final doctorRepositoryProvider = Provider<DoctorsRepository>((ref) {
  return DoctorsRepository(ref.read(supabaseClientProvider));
});
