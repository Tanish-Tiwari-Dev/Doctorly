import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'doctor_provider.dart';

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return <String>{};
    try {
      final client = ref.read(supabaseClientProvider);
      final res = await client
          .from('favorites')
          .select('doctor_id')
          .eq('user_id', userId);
      final ids = (res as List)
          .cast<Map<String, dynamic>>()
          .map((row) => row['doctor_id'] as String)
          .toSet();
      return ids;
    } catch (e, st) {
      throw AsyncError('Could not load favorites.', st);
    }
  }

  Future<void> toggle(String doctorId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(
        StateError('Not signed in'),
        StackTrace.current,
      );
      return;
    }
    final current = state.valueOrNull ?? <String>{};
    final client = ref.read(supabaseClientProvider);

    if (current.contains(doctorId)) {
      state = AsyncValue.data({...current}..remove(doctorId));
      try {
        await client
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('doctor_id', doctorId);
      } catch (e, st) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(e, st);
        rethrow;
      }
    } else {
      state = AsyncValue.data({...current, doctorId});
      try {
        await client.from('favorites').insert({
          'user_id': userId,
          'doctor_id': doctorId,
        });
      } catch (e, st) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(e, st);
        rethrow;
      }
    }
  }

  bool isFavorite(String doctorId) {
    return state.valueOrNull?.contains(doctorId) ?? false;
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
