import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/features/doctor/data/repositories/reports_repository.dart';
import 'package:doctorly/utils/repository_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late ReportsRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    repository = ReportsRepository(mockClient);
  });

  group('ReportsRepository Unit Tests', () {
    test('throws RepositoryException when user is not authenticated', () async {
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.submitReport(
          doctorId: 'doc-123',
          reason: 'Inaccurate information',
        ),
        throwsA(
          isA<RepositoryException>().having(
            (e) => e.kind,
            'kind',
            RepositoryExceptionKind.unauthorized,
          ),
        ),
      );
    });
  });
}
