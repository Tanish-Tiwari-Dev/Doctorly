import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:doctorly/services/logger.dart';

/// AsyncNotifier managing the onboarding completion state.
class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repository = ref.read(onboardingRepositoryProvider);
    return repository.hasSeenOnboarding();
  }

  /// Marks onboarding as completed and persists state to SharedPreferences.
  Future<void> completeOnboarding() async {
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      await repository.setHasSeenOnboarding(true);
      state = const AsyncValue.data(true);
      LoggerService.instance.log.info('Onboarding completed and saved.');
    } catch (e, st) {
      LoggerService.instance.log.severe(
        'Failed to save onboarding state',
        e,
        st,
      );
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for managing onboarding state.
final onboardingProvider = AsyncNotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
