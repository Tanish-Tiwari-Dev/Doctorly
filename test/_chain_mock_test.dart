import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}

class MockOrderBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

void main() {
  test('chain mock setup', () {
    final mockClient = MockSupabaseClient();
    final mockQueryBuilder = MockSupabaseQueryBuilder();
    final mockFilterBuilder = MockFilterBuilder<List<Map<String, dynamic>>>();
    final mockOrderBuilder = MockOrderBuilder<List<Map<String, dynamic>>>();

    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')),
    ).thenAnswer((_) => mockOrderBuilder);

    expect(mockClient.from('test'), mockQueryBuilder);
    expect(mockQueryBuilder.select(), mockFilterBuilder);
  });
}
