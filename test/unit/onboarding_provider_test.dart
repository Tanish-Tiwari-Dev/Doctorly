import 'package:doctorly/providers/onboarding_provider.dart';
import 'package:doctorly/repositories/onboarding_repository.dart';
import 'package:doctorly/services/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LoggerService.instance.initialize();
  });

  group('OnboardingRepository Unit Tests', () {
    test('hasSeenOnboarding returns false by default', () async {
      final repo = OnboardingRepository();
      final hasSeen = await repo.hasSeenOnboarding();
      expect(hasSeen, isFalse);
    });

    test('setHasSeenOnboarding persists true to SharedPreferences', () async {
      final repo = OnboardingRepository();
      await repo.setHasSeenOnboarding(true);

      final hasSeen = await repo.hasSeenOnboarding();
      expect(hasSeen, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });
  });

  group('OnboardingNotifier Unit Tests', () {
    test('build initial state is false', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(onboardingProvider.future);
      expect(state, isFalse);
    });

    test('completeOnboarding sets state to true', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initialize
      await container.read(onboardingProvider.future);

      await container.read(onboardingProvider.notifier).completeOnboarding();

      final state = container.read(onboardingProvider).valueOrNull;
      expect(state, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });
  });
}
