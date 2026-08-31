import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctorly/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen builds without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Your health,\nsimplified'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
