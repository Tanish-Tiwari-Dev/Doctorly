import 'package:doctorly/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SettingsScreen builds and shows Sign Out and Delete Account UI',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
    },
  );

  testWidgets('Tapping Delete Account shows confirmation dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Are you sure? This will permanently delete your account and all data. This action cannot be undone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Are you sure? This will permanently delete your account and all data. This action cannot be undone.',
      ),
      findsNothing,
    );
  });
}
