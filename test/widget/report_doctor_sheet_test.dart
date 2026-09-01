import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/presentation/widgets/report_doctor_sheet.dart';

void main() {
  testWidgets('ReportDoctorSheet renders predefined reasons and details textfield',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ReportDoctorSheet(
              doctorId: 'doc-123',
              doctorName: 'Dr. John Doe',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Report Dr. John Doe'), findsOneWidget);
    expect(find.text('Inaccurate information'), findsOneWidget);
    expect(find.text('Fake profile'), findsOneWidget);
    expect(find.text('Inappropriate behavior'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);

    // Select "Fake profile"
    await tester.tap(find.text('Fake profile'));
    await tester.pumpAndSettle();

    // Verify text field can take input
    await tester.enterText(find.byType(TextField), 'Test details text');
    expect(find.text('Test details text'), findsOneWidget);
  });
}
