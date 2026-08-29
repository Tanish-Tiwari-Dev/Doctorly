import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor.dart';

class DoctorRepository {
  DoctorRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all doctors from Supabase, ordered by [orderBy].
  ///
  /// Defaults to `rating desc` so the home screen shows the most
  /// highly-rated doctors first. Pass [orderBy] to override; supported
  /// column names are validated at the SQL level (PostgREST will reject
  /// unknown columns).
  Future<List<Doctor>> fetchAll({String orderBy = 'rating'}) async {
    final res = await _client.from('doctors').select().order(orderBy, ascending: false);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(Doctor.fromJson)
        .toList();
  }

  /// Fetches doctors near the given lat/lng using the PostGIS `nearby_doctors`
  /// RPC. Requires the function to exist (see supabase/schema.sql).
  Future<List<Doctor>> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
  }) async {
    final res = await _client.rpc('nearby_doctors', params: {
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm,
    });
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(Doctor.fromJson)
        .toList();
  }
}
