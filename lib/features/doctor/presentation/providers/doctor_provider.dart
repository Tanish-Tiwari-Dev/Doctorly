import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/domain/models/specialty.dart';
import 'package:doctorly/features/doctor/data/repositories/doctors_repository.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/utils/availability_checker.dart';
import 'package:doctorly/utils/error_localizer.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// AsyncNotifier managing the full list of doctor profiles fetched from [DoctorsRepository].
class DoctorsNotifier extends AsyncNotifier<List<Doctor>> {
  @override
  Future<List<Doctor>> build() async {
    final repo = ref.read(doctorRepositoryProvider);
    try {
      return await repo.fetchAll(orderBy: 'rating');
    } on RepositoryException catch (e) {
      throw AsyncError(localizeError(e), StackTrace.current);
    }
  }

  /// Forces a re-fetch of the doctor listing from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(doctorRepositoryProvider);
      try {
        return await repo.fetchAll(orderBy: 'rating');
      } on RepositoryException catch (e) {
        throw AsyncError(localizeError(e), StackTrace.current);
      }
    });
  }
}

/// Main async provider for listing doctors.
final doctorListProvider = AsyncNotifierProvider<DoctorsNotifier, List<Doctor>>(
  DoctorsNotifier.new,
);

/// Family provider returning a specific doctor by [id] from the loaded listing.
final doctorByIdProvider = Provider.family<Doctor?, String>((ref, id) {
  final doctors = ref.watch(doctorListProvider).valueOrNull;
  if (doctors == null) return null;
  final index = doctors.indexWhere((doctor) => doctor.id == id);
  return index == -1 ? null : doctors[index];
});

/// Auto-disposing provider fetching top-rated doctors with rating >= 4.5.
final topRatedDoctorsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final repo = ref.read(doctorRepositoryProvider);
  return await repo.fetchTopRated(minRating: 4.5, limit: 10);
});

/// State provider holding the currently selected specialty filter chip.
final selectedSpecialtyProvider = StateProvider<Specialty?>((ref) => null);

/// State provider holding optional nearby location search results.
final nearbyResultsProvider = StateProvider<List<Doctor>?>((ref) => null);

/// Notifier managing debounced search query input string.
class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return '';
  }

  /// Updates search query string with 300ms debounce.
  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = value;
    });
  }
}

/// Provider managing the debounced search query state.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Derived provider filtering doctor listing by search query, specialty, rating, and distance.
final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final filter = ref.watch(doctorFilterProvider);
  final nearby = ref.watch(nearbyResultsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final specialtyChip = ref.watch(selectedSpecialtyProvider);

  final sourceList =
      nearby ?? ref.watch(doctorListProvider).valueOrNull ?? const [];

  final sorted = List<Doctor>.of(sourceList);
  if (nearby == null) {
    sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  return sorted.where((doctor) {
    final matchQuery = query.isEmpty ||
        doctor.name.toLowerCase().contains(query) ||
        doctor.specialty.toLowerCase().contains(query);

    final matchSpecialtyChip =
        specialtyChip == null || doctor.specialty == specialtyChip.label;

    final matchFilterRating = doctor.rating >= filter.minRating;

    final matchFilterSpecialty = filter.specialty == null ||
        filter.specialty!.isEmpty ||
        doctor.specialty == filter.specialty;

    final matchFilterDistance = filter.maxDistanceKm >= 50 ||
        (doctor.distanceKm > 0 && doctor.distanceKm <= filter.maxDistanceKm) ||
        doctor.distanceKm == 0;

    final matchOpenNow = !filter.openNowOnly ||
        isDoctorOpen(doctor.openingTime, doctor.closingTime);

    return matchQuery &&
        matchSpecialtyChip &&
        matchFilterRating &&
        matchFilterSpecialty &&
        matchFilterDistance &&
        matchOpenNow;
  }).toList();
});

/// Record parameter type for similar doctors query.
typedef SimilarDoctorsParams = ({String doctorId, String specialty});

/// Auto-disposing family provider fetching similar doctors for a given doctor ID and specialty.
final similarDoctorsProvider =
    FutureProvider.autoDispose.family<List<Doctor>, SimilarDoctorsParams>(
  (ref, params) async {
    final repo = ref.watch(doctorRepositoryProvider);
    return repo.fetchSimilarDoctors(params.doctorId, params.specialty);
  },
);
