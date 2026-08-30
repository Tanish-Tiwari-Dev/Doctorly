import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../providers/supabase_client_provider.dart';
import '../repositories/auth_repository.dart';
import '../services/logger.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isMerging = false,
    this.mergeError,
  });

  final supabase.User? user;
  final bool isLoading;
  final bool isMerging;
  final String? mergeError;

  bool get isSignedIn => user != null;
  String? get userId => user?.id;
  String? get email => user?.email;

  AuthState copyWith({
    supabase.User? user,
    bool? isLoading,
    bool? isMerging,
    String? mergeError,
    bool clearMergeError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isMerging: isMerging ?? this.isMerging,
      mergeError: clearMergeError ? null : (mergeError ?? this.mergeError),
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription<void>? _subscription;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _previousUserId;

  @override
  Future<AuthState> build() async {
    final client = ref.read(supabaseClientProvider);
    _previousUserId = client.auth.currentUser?.id;

    _subscription = client.auth.onAuthStateChange.listen((_) {
      final user = client.auth.currentUser;
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
          isMerging: current?.isMerging ?? false,
          mergeError: current?.mergeError,
        ),
      );
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return AuthState(user: client.auth.currentUser, isLoading: false);
  }

  Future<void> signInAnonymously() async {
    final client = ref.read(supabaseClientProvider);
    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      await client.auth.signInAnonymously();
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_anonymous_user_id', userId);
      }
      state = AsyncValue.data(
        AuthState(user: client.auth.currentUser, isLoading: false),
      );
    } catch (e, st) {
      LoggerService.instance.log.severe('Anonymous sign-in failed', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        final client = ref.read(supabaseClientProvider);
        state = AsyncValue.data(
          AuthState(user: client.auth.currentUser, isLoading: false),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );
      state = AsyncValue.data(
        AuthState(user: client.auth.currentUser, isLoading: false),
      );
    } catch (e, st) {
      LoggerService.instance.log.severe('Google sign-in failed', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithOtp(String email) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithOtp(email: email, emailRedirectTo: null);
      final currentUser = client.auth.currentUser;
      state = AsyncValue.data(AuthState(user: currentUser, isLoading: false));
    } catch (e, st) {
      LoggerService.instance.log.severe('OTP sign-in failed', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _googleSignIn.signOut();
      final client = ref.read(supabaseClientProvider);
      await client.auth.signOut();
      await _clearCachedAnonymousUserId();
    } catch (e, st) {
      LoggerService.instance.log.severe('Sign out failed', e, st);
      state = AsyncValue.error(e, st);
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

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.valueOrNull?.userId;
});

final isMergingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.valueOrNull?.isMerging ?? false;
});
