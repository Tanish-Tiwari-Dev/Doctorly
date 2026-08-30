import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_client_provider.dart';

class AuthState {
  const AuthState({this.session, this.user});
  final Session? session;
  final User? user;

  String? get userId => user?.id ?? session?.user.id;

  bool get isSignedIn => user != null || session != null;

  String? get email => user?.email ?? session?.user.email;
}

/// Streams the current Supabase auth state. Seeded with whatever the client
/// already knows, then kept in sync via `onAuthStateChange`.
final authProvider = StreamProvider<AuthState>((ref) async* {
  final client = ref.read(supabaseClientProvider);

  AuthState snapshot() {
    final current = client.auth.currentSession;
    return AuthState(
      session: current,
      user: client.auth.currentUser,
    );
  }

  yield snapshot();

  await for (final event in client.auth.onAuthStateChange) {
    final session = event.session;
    yield AuthState(
      session: session,
      user: session?.user,
    );
  }
});

/// Returns the current Supabase user id, or `null` when no user is signed in.
/// Providers must treat `null` as "not signed in" and skip user-scoped work.
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authProvider).valueOrNull;
  return auth?.userId;
});
