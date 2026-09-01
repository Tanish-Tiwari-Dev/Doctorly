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

  /// Fetches all doctor profiles up to [limit], caches them locally, and falls back to cache on failure.
  ///
  /// [orderBy] determines the sorting column (defaults to 'rating').
  /// Optional [filter] applies rating, specialty, distance, and open-now criteria.
  /// Returns a list of [Doctor] objects.
  /// Throws [RepositoryException] if both network fetch and Hive cache access fail.
  Future<List<Doctor>> fetchAll({
    String orderBy = 'rating',
    DoctorFilter? filter,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('doctors').select();

      if (filter != null) {
        if (filter.minRating > 0) {
          query = query.gte('rating', filter.minRating);
        }
        if (filter.specialty != null && filter.specialty!.isNotEmpty) {
          query = query.eq('specialty', filter.specialty!);
        }
      }

      final res = await query.order(orderBy, ascending: false).limit(limit);
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
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches a doctor profile by [id], falling back to local cache on error.
  ///
  /// Returns matching [Doctor] or `null` if no doctor matches [id].
  /// Throws [RepositoryException] on database failure when no cache is available.
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
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          final match = cached.firstWhere(
            (row) => row['id'] == id,
            orElse: () => <String, dynamic>{},
          );
          if (match.isNotEmpty) {
            return Doctor.fromJson(match);
          }
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches doctors near the specified [lat] and [lng] coordinates within [radiusKm].
  ///
  /// Accepts optional [limit] and [filter] parameters.
  /// Returns a list of nearby [Doctor] objects sorted by distance.
  /// Throws [RepositoryException] on RPC or connection error when cache fails.
  Future<List<Doctor>> fetchNearby(
    double lat,
    double lng, {
    double radiusKm = 5,
    int limit = 20,
    DoctorFilter? filter,
  }) async {
    final searchRadius = (filter != null && filter.maxDistanceKm < 50)
        ? filter.maxDistanceKm.toDouble()
        : radiusKm;

    try {
      final res = await _client.rpc(
        'nearby_doctors',
        params: {'lat': lat, 'lng': lng, 'radius_km': searchRadius},
      );
      var list = (res as List)
          .cast<Map<String, dynamic>>()
          .map((row) => Doctor.fromJson(row))
          .toList();

      if (filter != null) {
        if (filter.minRating > 0) {
          list = list.where((d) => d.rating >= filter.minRating).toList();
        }
        if (filter.specialty != null && filter.specialty!.isNotEmpty) {
          list = list.where((d) => d.specialty == filter.specialty).toList();
        }
        if (filter.openNowOnly) {
          list = list
              .where((d) => isDoctorOpen(d.openingTime, d.closingTime))
              .toList();
        }
      }

      if (list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      try {
        final cached = await CacheService.instance.getCachedDoctors();
        if (cached != null && cached.isNotEmpty) {
          var list = cached.map((row) => Doctor.fromJson(row)).toList();
          if (filter != null) {
            if (filter.minRating > 0) {
              list = list.where((d) => d.rating >= filter.minRating).toList();
            }
            if (filter.specialty != null && filter.specialty!.isNotEmpty) {
              list = list.where((d) => d.specialty == filter.specialty).toList();
            }
            if (filter.openNowOnly) {
              list = list
                  .where((d) => isDoctorOpen(d.openingTime, d.closingTime))
                  .toList();
            }
          }
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Searches doctors matching [query] in name or specialty up to [limit].
  ///
  /// Returns matching [Doctor] list.
  /// Throws [RepositoryException] on query failure if Hive cache is unavailable.
  Future<List<Doctor>> searchDoctors(String query, {int limit = 20}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return fetchAll(limit: limit);
    }
    try {
      final res = await _client
          .from('doctors')
          .select()
          .or('name.ilike.%$cleanQuery%,specialty.ilike.%$cleanQuery%')
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
                  d.specialty.toLowerCase().contains(q))
              .toList();
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches top-rated doctors with rating >= [minRating], falling back to local cache on error.
  ///
  /// Returns a list of top-rated [Doctor] objects up to [limit].
  /// Throws [RepositoryException] on database error if cache read fails.
  Future<List<Doctor>> fetchTopRated({
    double minRating = 4.5,
    int limit = 10,
  }) async {
    try {
      final res = await _client
          .from('doctors')
          .select()
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
              .toList();
          list.sort((a, b) => b.rating.compareTo(a.rating));
          return list.length > limit ? list.sublist(0, limit) : list;
        }
      } catch (_) {}
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Fetches up to [limit] similar doctors with the same [specialty] excluding [currentDoctorId].
  ///
  /// Returns a list of [Doctor] objects.
  /// Throws [RepositoryException] on database error if cache read fails.
  Future<List<Doctor>> fetchSimilarDoctors(
    String currentDoctorId,
    String specialty, {
    int limit = 5,
  }) async {
    try {
      final res = await _client
          .from('doctors')
          .select()
          .eq('specialty', specialty)
          .neq('id', currentDoctorId)
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
              .where((d) => d.specialty == specialty && d.id != currentDoctorId)
              .toList();
          list.sort((a, b) => b.rating.compareTo(a.rating));
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
