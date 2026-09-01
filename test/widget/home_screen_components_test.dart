import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/widgets/specialty_grid.dart';
import 'package:doctorly/features/doctor/presentation/widgets/top_rated_carousel.dart';

void main() {
  group('Home Screen Components Tests', () {
    testWidgets('SpecialtyGrid renders specialties horizontal list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SpecialtyGrid(),
            ),
          ),
        ),
      );

      expect(find.text('Specialties'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('Dermatologist'), findsOneWidget);
      expect(find.text('Pediatrician'), findsOneWidget);
    });

    testWidgets('TopRatedCarousel renders loading and top rated doctors list',
        (WidgetTester tester) async {
      const sampleDoctor = Doctor(
        id: 'doc-1',
        name: 'Dr. Sarah Connor',
        specialty: 'Cardiologist',
        distanceKm: 2.5,
        rating: 4.9,
        imageUrl: 'https://example.com/doctor.jpg',
        availability: 'Available Today',
        hospitalName: 'Downtown Medical Center',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topRatedDoctorsProvider.overrideWith(
              (ref) => Future.value([sampleDoctor]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TopRatedCarousel(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top Rated Doctors'), findsOneWidget);
      expect(find.text('Dr. Sarah Connor'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Book'), findsOneWidget);
    });
  });
}
