import 'package:flutter_test/flutter_test.dart';
import 'package:doctorly/providers/auth_provider.dart';

void main() {
  group('AuthState Unit Tests', () {
    test('default AuthState has isMerging = false and mergeError = null', () {
      const state = AuthState();
      expect(state.isMerging, false);
      expect(state.mergeError, null);
      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.isSignedIn, false);
    });

    test('copyWith updates isMerging and mergeError correctly', () {
      const state = AuthState();
      final mergingState = state.copyWith(isMerging: true);

      expect(mergingState.isMerging, true);
      expect(mergingState.mergeError, null);

      final errorState = mergingState.copyWith(
        isMerging: false,
        mergeError: 'Could not sync guest data. Your account is ready.',
      );

      expect(errorState.isMerging, false);
      expect(errorState.mergeError, 'Could not sync guest data. Your account is ready.');

      final clearedState = errorState.copyWith(clearMergeError: true);
      expect(clearedState.mergeError, null);
      expect(clearedState.isMerging, false);
    });
  });
}
