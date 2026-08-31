import 'package:doctorly/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('AuthState Unit Tests', () {
    test('default AuthState has default values', () {
      const state = AuthState();
      expect(state.isMerging, false);
      expect(state.mergeError, null);
      expect(state.isLoading, false);
      expect(state.isSendingOtp, false);
      expect(state.isVerifyingOtp, false);
      expect(state.isSigningInGoogle, false);
      expect(state.isSigningInGuest, false);
      expect(state.otpSent, false);
      expect(state.emailForOtp, null);
      expect(state.authError, null);
      expect(state.user, null);
      expect(state.guestModeExplicitlyChosen, false);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isSignedIn, false);
    });

    test('AuthStatus resolves correctly for anonymous and authenticated users', () {
      const stateNoUser = AuthState(user: null);
      expect(stateNoUser.status, AuthStatus.unauthenticated);
      expect(stateNoUser.isSignedIn, false);

      final anonUser = supabase.User(
        id: 'anon-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        isAnonymous: true,
      );

      final stateAnonNotExplicit = AuthState(
        user: anonUser,
        guestModeExplicitlyChosen: false,
      );
      expect(stateAnonNotExplicit.status, AuthStatus.unauthenticated);
      expect(stateAnonNotExplicit.isSignedIn, false);
      expect(stateAnonNotExplicit.isGuest, false);

      final stateAnonExplicit = AuthState(
        user: anonUser,
        guestModeExplicitlyChosen: true,
      );
      expect(stateAnonExplicit.status, AuthStatus.guest);
      expect(stateAnonExplicit.isSignedIn, true);
      expect(stateAnonExplicit.isGuest, true);

      final realUser = supabase.User(
        id: 'user-456',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'doctor@example.com',
        isAnonymous: false,
      );

      final stateRealUser = AuthState(
        user: realUser,
        guestModeExplicitlyChosen: false,
      );
      expect(stateRealUser.status, AuthStatus.authenticated);
      expect(stateRealUser.isSignedIn, true);
      expect(stateRealUser.isAuthenticated, true);
      expect(stateRealUser.isGuest, false);
    });

    test('copyWith updates OTP states and authError correctly', () {
      const state = AuthState();
      final step1State = state.copyWith(
        isSendingOtp: true,
        emailForOtp: 'user@example.com',
        isSigningInGoogle: true,
        isSigningInGuest: true,
      );

      expect(step1State.isSendingOtp, true);
      expect(step1State.isSigningInGoogle, true);
      expect(step1State.isSigningInGuest, true);
      expect(step1State.emailForOtp, 'user@example.com');

      final step2State = step1State.copyWith(
        isSendingOtp: false,
        isSigningInGoogle: false,
        isSigningInGuest: false,
        otpSent: true,
      );

      expect(step2State.isSendingOtp, false);
      expect(step2State.isSigningInGoogle, false);
      expect(step2State.isSigningInGuest, false);
      expect(step2State.otpSent, true);

      final errorState = step2State.copyWith(
        authError: 'Invalid or expired verification code.',
      );

      expect(errorState.authError, 'Invalid or expired verification code.');

      final clearedErrorState = errorState.copyWith(clearAuthError: true);
      expect(clearedErrorState.authError, null);
      expect(clearedErrorState.otpSent, true);
    });

    test('humanizeAuthError formats AuthException correctly', () {
      const invalidOtpException = supabase.AuthException(
        'Invalid OTP token',
        statusCode: '400',
      );
      expect(
        humanizeAuthError(invalidOtpException),
        'Invalid or expired verification code. Please request a new code.',
      );

      const rateLimitException = supabase.AuthException(
        'Too many requests rate limit exceeded',
        statusCode: '429',
      );
      expect(
        humanizeAuthError(rateLimitException),
        'Too many attempts. Please wait a minute before trying again.',
      );
    });
  });
}
