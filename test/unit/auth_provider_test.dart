import 'package:doctorly/providers/auth_provider.dart';
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
      expect(state.isSignedIn, false);
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
