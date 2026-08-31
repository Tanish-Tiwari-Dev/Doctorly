import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../repositories/auth_repository.dart';
import '../services/logger.dart';

/// State representation for authentication status.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isSigningInGoogle = false,
    this.isSigningInGuest = false,
    this.otpSent = false,
    this.emailForOtp,
    this.authError,
    this.isMerging = false,
    this.mergeError,
  });

  final supabase.User? user;
  final bool isLoading;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isSigningInGoogle;
  final bool isSigningInGuest;
  final bool otpSent;
  final String? emailForOtp;
  final String? authError;
  final bool isMerging;
  final String? mergeError;

  bool get isSignedIn => user != null;
  bool get isAuthenticated => user != null;
  String? get userId => user?.id;
  String? get email => user?.email;

  AuthState copyWith({
    supabase.User? user,
    bool? isLoading,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isSigningInGoogle,
    bool? isSigningInGuest,
    bool? otpSent,
    String? emailForOtp,
    String? authError,
    bool clearAuthError = false,
    bool? isMerging,
    String? mergeError,
    bool clearMergeError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isSigningInGoogle: isSigningInGoogle ?? this.isSigningInGoogle,
      isSigningInGuest: isSigningInGuest ?? this.isSigningInGuest,
      otpSent: otpSent ?? this.otpSent,
      emailForOtp: emailForOtp ?? this.emailForOtp,
      authError: clearAuthError ? null : (authError ?? this.authError),
      isMerging: isMerging ?? this.isMerging,
      mergeError: clearMergeError ? null : (mergeError ?? this.mergeError),
    );
  }
}

/// Helper function to convert authentication errors to human-readable strings.
String humanizeAuthError(Object error) {
  if (error is supabase.AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid otp') ||
        msg.contains('otp expired') ||
        msg.contains('token has expired') ||
        msg.contains('invalid token')) {
      return 'Invalid or expired verification code. Please request a new code.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a minute before trying again.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Incorrect credentials. Please try again.';
    }
    return error.message;
  }
  return error.toString();
}

/// Notifier managing authentication state and actions.
class AuthNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription<void>? _subscription;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _previousUserId;

  @override
  Future<AuthState> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    _previousUserId = authRepo.currentUser?.id;

    _subscription = authRepo.onAuthStateChange.listen((_) {
      final user = authRepo.currentUser;
      final newUserId = user?.id;

      if (newUserId != null &&
          _previousUserId != null &&
          newUserId != _previousUserId) {
        _attemptMergeIfNeeded(newUserId);
      }

      _previousUserId = newUserId;
      final current = state.valueOrNull;
      state = AsyncValue.data(
        AuthState(
          user: user,
          isLoading: false,
          isSendingOtp: false,
          isVerifyingOtp: false,
          isSigningInGoogle: false,
          isSigningInGuest: false,
          otpSent: user != null ? false : (current?.otpSent ?? false),
          emailForOtp: user != null ? null : current?.emailForOtp,
          isMerging: current?.isMerging ?? false,
          mergeError: current?.mergeError,
        ),
      );
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return AuthState(user: authRepo.currentUser, isLoading: false);
  }

  /// Sends an 8-digit OTP code to the specified [email].
  Future<void> sendOtp(String email) async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isSendingOtp: true, clearAuthError: true),
    );
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithOtp(email);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(
          isSendingOtp: false,
          otpSent: true,
          emailForOtp: email,
        ),
      );
      LoggerService.instance.log.info('OTP code sent successfully to $email');
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to send OTP code', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(isSendingOtp: false, authError: humanizeAuthError(e)),
      );
    }
  }

  /// Verifies the 8-digit OTP [token] for the stored email address.
  Future<void> verifyOtp(String token) async {
    final current = state.valueOrNull ?? const AuthState();
    final email = current.emailForOtp;
    if (email == null || email.isEmpty) {
      state = AsyncValue.data(
        current.copyWith(
          authError: 'Session expired. Please request a new code.',
        ),
      );
      return;
    }

    state = AsyncValue.data(
      current.copyWith(isVerifyingOtp: true, clearAuthError: true),
    );
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(email: email, token: token);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(
          isVerifyingOtp: false,
          otpSent: false,
          emailForOtp: null,
          user: repo.currentUser,
        ),
      );
      LoggerService.instance.log.info('OTP verification successful');
    } catch (e, st) {
      LoggerService.instance.log.severe('OTP verification failed', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(
          isVerifyingOtp: false,
          authError: humanizeAuthError(e),
        ),
      );
    }
  }

  /// Resets the OTP step back to email entry (Step 1).
  void resetOtpStep() {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(otpSent: false, emailForOtp: null, clearAuthError: true),
    );
  }

  /// Clears any active authentication error message.
  void clearAuthError() {
    final current = state.valueOrNull;
    if (current != null && current.authError != null) {
      state = AsyncValue.data(current.copyWith(clearAuthError: true));
    }
  }

  /// Initiates Google OAuth sign in.
  Future<void> signInWithGoogle() async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isSigningInGoogle: true, clearAuthError: true),
    );
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.signInWithGoogle();
      if (response == null) {
        final updated = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(updated.copyWith(isSigningInGoogle: false));
        return;
      }
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(user: repo.currentUser, isSigningInGoogle: false),
      );
    } catch (e, st) {
      LoggerService.instance.log.severe('Google sign-in failed', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(
          isSigningInGoogle: false,
          authError: humanizeAuthError(e),
        ),
      );
    }
  }

  /// Signs in anonymously as a guest user.
  Future<void> signInAnonymously() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo.currentUser != null) {
      return;
    }

    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      current.copyWith(isSigningInGuest: true, clearAuthError: true),
    );
    try {
      await repo.signInAnonymously();
      final userId = repo.currentUser?.id;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_anonymous_user_id', userId);
      }
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(user: repo.currentUser, isSigningInGuest: false),
      );
    } catch (e, st) {
      LoggerService.instance.log.severe('Anonymous sign-in failed', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(
          isSigningInGuest: false,
          authError: humanizeAuthError(e),
        ),
      );
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(current.copyWith(isLoading: true));
    try {
      await _googleSignIn.signOut();
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
      await _clearCachedAnonymousUserId();
      state = const AsyncValue.data(AuthState(user: null, isLoading: false));
    } catch (e, st) {
      LoggerService.instance.log.severe('Sign out failed', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(isLoading: false, authError: humanizeAuthError(e)),
      );
    }
  }

  /// Deletes the current user's account and signs out.
  Future<void> deleteAccount() async {
    final current = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(current.copyWith(isLoading: true));
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.deleteUserAccount();
      await signOut();
      LoggerService.instance.log.info('User account deleted successfully.');
    } catch (e, st) {
      LoggerService.instance.log.severe('Account deletion failed', e, st);
      final updated = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        updated.copyWith(isLoading: false, authError: humanizeAuthError(e)),
      );
      rethrow;
    }
  }

  Future<void> _attemptMergeIfNeeded(String newUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedAnonId = prefs.getString('cached_anonymous_user_id');
    if (cachedAnonId == null || cachedAnonId == newUserId) {
      return;
    }

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(isMerging: true, clearMergeError: true),
      );
    }

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.mergeAnonymousData(cachedAnonId, newUserId);
      await _clearCachedAnonymousUserId();
      LoggerService.instance.log.info('Merged anonymous data', {
        'old_anon_id': cachedAnonId,
        'new_user_id': newUserId,
      });
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(updated.copyWith(isMerging: false));
      }
    } catch (e, st) {
      LoggerService.instance.log.severe(
        'Failed to merge anonymous data',
        e,
        st,
      );
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(
          updated.copyWith(
            isMerging: false,
            mergeError: 'Could not sync guest data. Your account is ready.',
          ),
        );
      }
    }
  }

  /// Clears any active data merge error.
  void clearMergeError() {
    final current = state.valueOrNull;
    if (current != null && current.mergeError != null) {
      state = AsyncValue.data(current.copyWith(clearMergeError: true));
    }
  }

  Future<void> _clearCachedAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_anonymous_user_id');
  }
}

/// Provider for managing authentication state and actions.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider returning the current user's ID.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.valueOrNull?.userId;
});

/// Provider returning whether guest data is currently merging.
final isMergingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.valueOrNull?.isMerging ?? false;
});
