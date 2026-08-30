import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/doctor.dart';
import '../models/specialty.dart';
import '../repositories/doctors_repository.dart';
import '../utils/error_localizer.dart';
import '../utils/repository_exception.dart';

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

final doctorListProvider = AsyncNotifierProvider<DoctorsNotifier, List<Doctor>>(
  DoctorsNotifier.new,
);

final doctorByIdProvider = Provider.family<Doctor?, String>((ref, id) {
  final doctors = ref.watch(doctorListProvider).valueOrNull;
  if (doctors == null) return null;
  final index = doctors.indexWhere((doctor) => doctor.id == id);
  return index == -1 ? null : doctors[index];
});

final topRatedDoctorsProvider = Provider<AsyncValue<List<Doctor>>>((ref) {
  return ref.watch(doctorListProvider).whenData((doctors) {
    final sorted = [...doctors]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  });
});

final selectedSpecialtyProvider = StateProvider<Specialty?>((ref) => null);

final nearbyResultsProvider = StateProvider<List<Doctor>?>((ref) => null);

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return '';
  }

  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = value;
    });
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final nearby = ref.watch(nearbyResultsProvider);
  if (nearby != null) {
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final specialty = ref.watch(selectedSpecialtyProvider);
    return nearby.where((d) {
      final matchQuery =
          query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query);
      final matchSpecialty =
          specialty == null || d.specialty == specialty.label;
      return matchQuery && matchSpecialty;
    }).toList();
  }

  final doctors = ref.watch(doctorListProvider).valueOrNull ?? const [];
  final sorted = List<Doctor>.of(doctors);
  sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final specialty = ref.watch(selectedSpecialtyProvider);
  return sorted.where((doctor) {
    final matchQuery =
        query.isEmpty ||
        doctor.name.toLowerCase().contains(query) ||
        doctor.specialty.toLowerCase().contains(query);
    final matchSpecialty =
        specialty == null || doctor.specialty == specialty.label;
    return matchQuery && matchSpecialty;
  }).toList();
});
