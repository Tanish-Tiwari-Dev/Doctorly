import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/widgets/top_rated_doctor_card.dart';

void main() {
  group('Home Screen Component Tests', () {
    testWidgets('TopRatedDoctorCard renders doctor details correctly',
        (WidgetTester tester) async {
      const sampleDoctor = Doctor(
        id: 'doc-1',
        name: 'Dr. Sarah Connor',
        specialty: 'Cardiologist',
        distanceKm: 2.5,
        rating: 4.9,
        imageUrl: '',
        availability: 'Available Today',
        hospitalName: 'Downtown Medical Center',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TopRatedDoctorCard(doctor: sampleDoctor),
          ),
        ),
      );

      expect(find.text('Dr. Sarah Connor'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Book Seat'), findsOneWidget);
    });
  });
}
