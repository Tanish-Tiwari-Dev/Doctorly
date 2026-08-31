import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository for managing authentication calls via Supabase.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  static const String guestModeExplicitlyChosenKey =
      'guest_mode_explicitly_chosen';

  /// Checks if guest mode was explicitly chosen by the user.
  Future<bool> isGuestModeExplicitlyChosen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(guestModeExplicitlyChosenKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets whether guest mode was explicitly chosen by the user.
  Future<void> setGuestModeExplicitlyChosen(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(guestModeExplicitlyChosenKey, value);
    } catch (_) {}
  }

  /// Explicitly enters guest mode by setting the persistence flag and signing in anonymously.
  Future<AuthResponse> enterGuestMode() async {
    await setGuestModeExplicitlyChosen(true);
    return await signInAnonymously();
  }

  /// Gets the current Supabase user.
  User? get currentUser => _client.auth.currentUser;

  /// Stream of authentication state changes.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Requests a passwordless Email OTP to be sent to [email].
  Future<void> signInWithOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email, emailRedirectTo: null);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Verifies the 8-digit Email OTP [token] for [email].
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '265663218425-l00agv3jvi9a0e5tlqvd0vc6e92ns9pj.apps.googleusercontent.com',
  );

  /// Signs in using Google OAuth flow via [GoogleSignIn].
  /// Returns [AuthResponse] on success, or `null` if the user cancels.
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: googleWebClientId.isNotEmpty ? googleWebClientId : null,
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        return null;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;
      if (idToken == null || idToken.isEmpty) {
        throw const RepositoryException(
          RepositoryExceptionKind.unauthorized,
          'Google Auth ID token is unavailable. Ensure Web Client ID is configured in Google Cloud Console and Supabase Dashboard.',
        );
      }
      return await signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' ||
          e.code == 'canceled' ||
          e.code == 'network_error') {
        return null;
      }
      throw RepositoryException(classifyError(e), e.message ?? e.toString());
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Signs in using an OAuth ID token.
  Future<AuthResponse> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
  }) async {
    try {
      return await _client.auth.signInWithIdToken(
        provider: provider,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Signs in anonymously.
  Future<AuthResponse> signInAnonymously() async {
    try {
      return await _client.auth.signInAnonymously();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await setGuestModeExplicitlyChosen(false);
      await _client.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Merges anonymous data into a newly authenticated user account.
  Future<void> mergeAnonymousData(String oldAnonId, String newUserId) async {
    try {
      await _client.rpc(
        'merge_anonymous_data',
        params: {'p_old_anon_id': oldAnonId, 'p_new_user_id': newUserId},
      );
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }

  /// Deletes the current user's account and associated data via RPC.
  Future<void> deleteUserAccount() async {
    try {
      await setGuestModeExplicitlyChosen(false);
      await _client.rpc('delete_user_account');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseClientProvider));
});
