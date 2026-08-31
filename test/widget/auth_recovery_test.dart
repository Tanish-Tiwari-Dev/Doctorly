import 'package:doctorly/features/auth/data/repositories/auth_repository.dart';
import 'package:doctorly/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(() => mockAuthRepository.onAuthStateChange)
        .thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
      child: const MaterialApp(home: AuthScreen()),
    );
  }

  testWidgets(
    'renders "Having trouble signing in?" button on AuthScreen Step 1',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Having trouble signing in?'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "Having trouble signing in?" opens Account Recovery dialog with explanatory text',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Having trouble signing in?'));
      await tester.pumpAndSettle();

      expect(find.text('Account Recovery'), findsOneWidget);
      expect(
        find.text(
          'If you are having trouble accessing your account, enter your email below to receive a secure 8-digit recovery code.',
        ),
        findsOneWidget,
      );
      expect(find.text('Send Recovery Code'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    },
  );

  testWidgets(
    'submitting Account Recovery dialog with valid email calls sendOtp and transitions view',
    (WidgetTester tester) async {
      when(() => mockAuthRepository.signInWithOtp('recovery@example.com'))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Having trouble signing in?'));
      await tester.pumpAndSettle();

      final emailField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(emailField, 'recovery@example.com');
      await tester.tap(find.text('Send Recovery Code'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.signInWithOtp('recovery@example.com'))
          .called(1);
      expect(find.text('Enter Code'), findsOneWidget);
    },
  );
}
