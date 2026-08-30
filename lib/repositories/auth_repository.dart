import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_client_provider.dart';
import '../utils/repository_exception.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

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
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseClientProvider));
});
