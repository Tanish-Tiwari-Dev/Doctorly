import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/presentation/widgets/verified_badge.dart';

void main() {
  group('VerifiedBadge Widget Tests', () {
    testWidgets('renders Verified badge text and icon for fully verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(),
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('renders compact Verified badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(compact: true),
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('renders Pending verification badge when partiallyVerified is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(partiallyVerified: true),
          ),
        ),
      );

      expect(find.text('Pending verification'), findsOneWidget);
      expect(find.byIcon(Icons.pending_outlined), findsOneWidget);
      expect(find.text('Verified'), findsNothing);
    });
  });
}
