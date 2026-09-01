import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/presentation/widgets/leave_review_sheet.dart';

void main() {
  testWidgets('LeaveReviewSheet renders star ratings, text input and submit button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => LeaveReviewSheet.show(
                  context,
                  doctorId: 'doc-1',
                  doctorName: 'Dr. John Doe',
                ),
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      ),
    );

    // Open bottom sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify title and doctor name
    expect(find.text('Review Dr. John Doe'), findsOneWidget);
    expect(find.text('Tap to Rate'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);

    // Verify 5 star rating icons are rendered
    expect(find.byIcon(Icons.star), findsNWidgets(5));

    // Verify comment text field
    expect(find.byType(TextField), findsOneWidget);
  });
}
