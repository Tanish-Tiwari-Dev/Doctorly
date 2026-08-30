import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/doctor_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final allDoctors = ref.watch(doctorListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: Theme.of(context).textTheme.titleMedium),
        centerTitle: false,
      ),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load favorites.',
          subtitle: e.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
        data: (ids) {
          final doctors = allDoctors.valueOrNull ?? const [];
          final favorites = doctors.where((d) => ids.contains(d.id)).toList();
          if (favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet.',
              subtitle: 'Tap the heart on any doctor to save them.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return DoctorCard(doctor: favorites[index]);
            },
          );
        },
      ),
    );
  }
}
