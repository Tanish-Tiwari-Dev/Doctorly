import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor.dart';
import '../utils/mock_doctors.dart';

final doctorListProvider = Provider<List<Doctor>>((ref) {
  return mockDoctors;
});

final doctorByIdProvider = Provider.family<Doctor?, int>((ref, id) {
  final doctors = ref.watch(doctorListProvider);
  final index = doctors.indexWhere((doctor) => doctor.id == id);
  return index == -1 ? null : doctors[index];
});

final sortedDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorListProvider);
  final sorted = List<Doctor>.of(doctors);
  sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return sorted;
});
