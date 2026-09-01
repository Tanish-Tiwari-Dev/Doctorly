import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/presentation/widgets/doctor_filter_sheet.dart';

void main() {
  testWidgets(
      'DoctorFilterSheet renders sliders, specialty dropdown, apply and reset buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => DoctorFilterSheet.show(context),
                  child: const Text('Open Filter'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Filter Doctors'), findsOneWidget);
    expect(find.text('Minimum Rating'), findsOneWidget);
    expect(find.text('Maximum Distance'), findsOneWidget);
    expect(find.text('Specialty'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(DropdownButton<String?>), findsOneWidget);
  });
}
