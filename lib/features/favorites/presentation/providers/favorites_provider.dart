import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/auth/presentation/providers/auth_provider.dart';
import 'package:doctorly/features/favorites/data/repositories/favorites_repository.dart';
import 'package:doctorly/utils/error_localizer.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// AsyncNotifier managing the set of favorite doctor IDs for the current user.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return <String>{};
    try {
      final repo = ref.read(favoritesRepositoryProvider);
      return await repo.fetchForUser(userId);
    } on RepositoryException catch (e) {
      throw AsyncError(localizeError(e), StackTrace.current);
    } catch (e, st) {
      throw AsyncError('Could not load favorites.', st);
    }
  }

  /// Toggles the favorite status of [doctorId] for the logged-in user.
  /// Optimistically updates state and rolls back if the backend operation fails.
  Future<void> toggle(String doctorId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error(StateError('Not signed in'), StackTrace.current);
      return;
    }
    final current = state.valueOrNull ?? <String>{};
    final repo = ref.read(favoritesRepositoryProvider);

    if (current.contains(doctorId)) {
      state = AsyncValue.data({...current}..remove(doctorId));
      try {
        await repo.remove(userId, doctorId);
      } on RepositoryException catch (e) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(localizeError(e), StackTrace.current);
        rethrow;
      } catch (e, st) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(e, st);
        rethrow;
      }
    } else {
      state = AsyncValue.data({...current, doctorId});
      try {
        await repo.add(userId, doctorId);
      } on RepositoryException catch (e) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(localizeError(e), StackTrace.current);
        rethrow;
      } catch (e, st) {
        state = AsyncValue.data(current);
        state = AsyncValue.error(e, st);
        rethrow;
      }
    }
  }

  /// Checks if [doctorId] is currently in the set of user favorites.
  bool isFavorite(String doctorId) {
    return state.valueOrNull?.contains(doctorId) ?? false;
  }
}

/// Provider managing user favorite doctor IDs.
final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
