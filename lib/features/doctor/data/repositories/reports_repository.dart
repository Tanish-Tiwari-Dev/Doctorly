import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/providers/supabase_client_provider.dart';
import 'package:doctorly/utils/repository_exception.dart';

/// Repository handling submission of user reports for doctor profiles.
class ReportsRepository {
  ReportsRepository(this._client);

  final SupabaseClient _client;

  /// Submits a new report for the specified [doctorId] with [reason] and optional [details].
  Future<void> submitReport({
    required String doctorId,
    required String reason,
    String? details,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const RepositoryException(
        RepositoryExceptionKind.unauthorized,
        'User is not authenticated',
      );
    }

    try {
      await _client.from('reports').insert({
        'reporter_id': userId,
        'reported_doctor_id': doctorId,
        'reason': reason,
        'details': details,
        'status': 'pending',
      });
    } catch (e) {
      throw RepositoryException(classifyError(e), e.toString());
    }
  }
}

/// Provider for accessing [ReportsRepository].
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.read(supabaseClientProvider));
});
