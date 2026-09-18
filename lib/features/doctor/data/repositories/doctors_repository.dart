import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/services/cache_service.dart';
import 'package:doctorly/utils/availability_checker.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository handling doctor listing queries from Supabase with offline Hive fallback.
class DoctorsRepository {
  /// Creates a [DoctorsRepository] with the provided [SupabaseClient].
  DoctorsRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all doctor profiles (or up to [limit] if specified), caches them locally, and falls back to cache on failure.
  Future<List<Doctor>> fetchAll({
    String orderBy = 'rating',
    DoctorFilter? filter,
    int? limit,
  }) async {
    try {
      var query = _client.from('doctors').select(
        '*, doctor_services(status, services(slug, name))',
      );

      if (filter != null) {
        if (filter.minRating > 0) {
          query = query.gte('rating', filter.minRating);
        }
        if (filter.specialty != null && filter.specialty!.isNotEmpty) {
          query = query.eq('specialty', filter.specialty!);
        }
        if (filter.district != null && filter.district!.isNotEmpty) {
          query = query.eq('district', filter.district!);
        }
      }

      var orderedQuery = query.order(orderBy, ascending: false);
      final dynamic res;
      if (limit != null) {
        res = await orderedQuery.limit(limit);
      } else {
        res = await orderedQuery;
      }
      final list = (res as List).cast<Map<String, dynamic>>();
      await CacheService.instance.cacheDoctors(list);
      var doctors = list.map((row) => Doctor.fromJson(row)).toList();
      if (filter != null) {
        if (filter.maxDistanceKm < 50) {
          doctors = doctors
              .where((d) => d.distanceKm <= filter.maxDistanceKm)
              .toList();
        }
        if (filter.openNowOnly) {
          doctors = doctors
              .where((d) => isDoctorOpen(d.openingTime, d.closingTime))
              .toList();
        }
      }
      return doctors;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          var doctors = cached.map((row) => Doctor.fromJson(row)).toList();
          if (filter != null) {
            if (filter.minRating > 0) {
              doctors = doctors.where((d) => d.rating >= filter.minRating).toList();
            }
            if (filter.specialty != null && filter.specialty!.isNotEmpty) {
              doctors =
                  doctors.where((d) => d.specialty == filter.specialty).toList();
            }
            if (filter.district != null && filter.district!.isNotEmpty) {
              doctors =
                  doctors.where((d) => d.district?.toLowerCase() == filter.district!.toLowerCase()).toList();
            }
            if (filter.maxDistanceKm < 50) {
              doctors = doctors
                  .where((d) => d.distanceKm <= filter.maxDistanceKm)
                  .toList();
            }
            if (filter.openNowOnly) {
              doctors = doctors
                  .where((d) => isDoctorOpen(d.openingTime, d.closingTime))
                  .toList();
            }
          }
          if (limit != null && doctors.length > limit) {
            return doctors.sublist(0, limit);
          }
          return doctors;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches a doctor profile by [id], falling back to local cache on error.
  Future<Doctor?> fetchById(String id) async {
    try {
      final res = await _client
          .from('doctors')
          .select('*, doctor_services(status, services(slug, name))')
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return Doctor.fromJson(res);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          final match = cached.cast<Map<String, dynamic>?>().firstWhere(
                (row) => row != null && row['id'] == id,
                orElse: () => null,
              );
          if (match != null) {
            return Doctor.fromJson(match);
          }
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches doctors near a geographic coordinate using the `nearby_doctors` PostGIS RPC.
  Future<List<Doctor>> fetchNearby(
    double lat,
    double lng, {
    double radiusKm = 10,
    DoctorFilter? filter,
    int limit = 50,
  }) async {
    try {
      final res = await _client.rpc(
        'nearby_doctors',
        params: {'lat': lat, 'lng': lng, 'radius_km': radiusKm},
      );

      final list = (res as List).cast<Map<String, dynamic>>();
      var doctors = list.map((row) => Doctor.fromJson(row)).toList();

      if (filter != null) {
        if (filter.minRating > 0) {
          doctors = doctors.where((d) => d.rating >= filter.minRating).toList();
        }
        if (filter.specialty != null && filter.specialty!.isNotEmpty) {
          doctors =
              doctors.where((d) => d.specialty == filter.specialty).toList();
        }
        if (filter.district != null && filter.district!.isNotEmpty) {
          doctors =
              doctors.where((d) => d.district?.toLowerCase() == filter.district!.toLowerCase()).toList();
        }
        if (filter.maxDistanceKm < 50) {
          doctors = doctors
              .where((d) => d.distanceKm <= filter.maxDistanceKm)
              .toList();
        }
        if (filter.openNowOnly) {
          doctors = doctors
              .where((d) => isDoctorOpen(d.openingTime, d.closingTime))
              .toList();
        }
      }

      return doctors.length > limit ? doctors.sublist(0, limit) : doctors;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Searches doctors matching [query] in name or specialty up to [limit].
  Future<List<Doctor>> searchDoctors(String query, {int limit = 20}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return fetchAll(limit: limit);
    }
    try {
      final res = await _client
          .from('doctors')
          .select('*, doctor_services(status, services(slug, name))')
          .or('name.ilike.%$cleanQuery%,specialty.ilike.%$cleanQuery%,hospital_name.ilike.%$cleanQuery%,district.ilike.%$cleanQuery%')
          .order('rating', ascending: false)
          .limit(limit);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map((row) => Doctor.fromJson(row)).toList();
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          final q = cleanQuery.toLowerCase();
          final list = cached
              .map((row) => Doctor.fromJson(row))
              .where((d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.specialty.toLowerCase().contains(q) ||
                  (d.hospitalName?.toLowerCase().contains(q) ?? false) ||
                  (d.district?.toLowerCase().contains(q) ?? false))
              .toList();
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches top-rated doctors with rating >= [minRating], falling back to local cache on error.
  Future<List<Doctor>> fetchTopRated({
    double minRating = 4.5,
    int limit = 10,
  }) async {
    try {
      final res = await _client
          .from('doctors')
          .select('*, doctor_services(status, services(slug, name))')
          .gte('rating', minRating)
          .order('rating', ascending: false)
          .limit(limit);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map((row) => Doctor.fromJson(row)).toList();
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          final list = cached
              .map((row) => Doctor.fromJson(row))
              .where((d) => d.rating >= minRating)
              .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches similar doctors for a given doctor ID and specialty.
  Future<List<Doctor>> fetchSimilarDoctors(
    String doctorId,
    String specialty, {
    int limit = 4,
  }) async {
    try {
      final res = await _client
          .from('doctors')
          .select('*, doctor_services(status, services(slug, name))')
          .eq('specialty', specialty)
          .neq('id', doctorId)
          .order('rating', ascending: false)
          .limit(limit);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map((row) => Doctor.fromJson(row)).toList();
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          final list = cached
              .map((row) => Doctor.fromJson(row))
              .where((d) => d.specialty == specialty && d.id != doctorId)
              .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [DoctorsRepository].
final doctorRepositoryProvider = Provider<DoctorsRepository>((ref) {
  return DoctorsRepository(ref.read(supabaseClientProvider));
});
