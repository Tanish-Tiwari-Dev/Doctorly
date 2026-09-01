import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/appointments/presentation/screens/appointments_screen.dart';
import 'package:doctorly/features/appointments/presentation/widgets/appointment_card_skeleton.dart';
import 'package:doctorly/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:doctorly/features/favorites/presentation/widgets/favorite_card_skeleton.dart';

void main() {
  testWidgets('AppointmentsScreen renders Skeleton loading state when loading',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppointmentsScreen(),
        ),
      ),
    );

    expect(find.byType(AppointmentCardSkeleton), findsWidgets);
  });

  testWidgets('FavoritesScreen renders Skeleton loading state when loading',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );

    expect(find.byType(FavoriteCardSkeleton), findsWidgets);
  });
}
