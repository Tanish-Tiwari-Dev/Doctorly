import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for handling onboarding persistence in SharedPreferences.
class OnboardingRepository {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Returns true if the user has completed onboarding, false otherwise.
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Saves the onboarding completion status to SharedPreferences.
  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }
}

/// Provider for accessing the [OnboardingRepository].
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});
