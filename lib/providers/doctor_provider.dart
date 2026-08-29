import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';
import '../models/doctor.dart';
import '../models/specialty.dart';
import '../repositories/doctor_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // Supabase.instance throws an assertion if accessed before
  // Supabase.initialize() ran. Surface a clearer error instead.
  if (!Env.isConfigured) {
    throw StateError(
      'Supabase is not configured. Add SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY to a .env file (see .env.example) or pass '
      'them via --dart-define.',
    );
  }
  return Supabase.instance.client;
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(supabaseClientProvider));
});

class DoctorsNotifier extends AsyncNotifier<List<Doctor>> {
  @override
  Future<List<Doctor>> build() async {
    final repo = ref.read(doctorRepositoryProvider);
    return repo.fetchAll(orderBy: 'rating');
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(doctorRepositoryProvider);
      return repo.fetchAll(orderBy: 'rating');
    });
  }
}

final doctorListProvider =
    AsyncNotifierProvider<DoctorsNotifier, List<Doctor>>(DoctorsNotifier.new);

final doctorByIdProvider = Provider.family<Doctor?, String>((ref, id) {
  final doctors = ref.watch(doctorListProvider).valueOrNull;
  if (doctors == null) return null;
  final index = doctors.indexWhere((doctor) => doctor.id == id);
  return index == -1 ? null : doctors[index];
});

final sortedDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorListProvider).valueOrNull ?? const [];
  final sorted = List<Doctor>.of(doctors);
  sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return sorted;
});

final topRatedDoctorsProvider = Provider<AsyncValue<List<Doctor>>>((ref) {
  return ref.watch(doctorListProvider).whenData((doctors) {
    final sorted = [...doctors]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  });
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedSpecialtyProvider = StateProvider<Specialty?>((ref) => null);

final nearbyResultsProvider = StateProvider<List<Doctor>?>((ref) => null);

final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final nearby = ref.watch(nearbyResultsProvider);
  if (nearby != null) {
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final specialty = ref.watch(selectedSpecialtyProvider);
    return nearby.where((d) {
      final matchQuery = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query);
      final matchSpecialty =
          specialty == null || d.specialty == specialty.label;
      return matchQuery && matchSpecialty;
    }).toList();
  }

  final doctors = ref.watch(sortedDoctorsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final specialty = ref.watch(selectedSpecialtyProvider);
  return doctors.where((doctor) {
    final matchQuery = query.isEmpty ||
        doctor.name.toLowerCase().contains(query) ||
        doctor.specialty.toLowerCase().contains(query);
    final matchSpecialty =
        specialty == null || doctor.specialty == specialty.label;
    return matchQuery && matchSpecialty;
  }).toList();
});
