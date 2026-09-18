import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/widgets/doctor_card.dart';

void main() {
  group('DoctorCard Widget Tests', () {
    testWidgets('renders verified badge for verified doctor', (tester) async {
      const doctor = Doctor(
        id: 'doc-verified',
        name: 'Dr. Rajesh Varma',
        specialty: 'Neurosurgery',
        distanceKm: 2.5,
        rating: 4.8,
        imageUrl: '',
        availability: 'Available Today',
        hospitalName: 'Apex Neuro Institute',
        district: 'Ahmedabad',
        verificationStatus: 'verified',
        isVerified: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoctorCard(doctor: doctor),
          ),
        ),
      );

      expect(find.text('Dr. Rajesh Varma'), findsOneWidget);
      expect(find.text('Apex Neuro Institute • Ahmedabad'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('renders Pending verification chip for partially verified doctor', (tester) async {
      const doctor = Doctor(
        id: 'doc-partially-verified',
        name: 'Dr. Priya Mehta',
        specialty: 'Neurosurgery',
        distanceKm: 3.2,
        rating: 4.6,
        imageUrl: '',
        availability: 'Available Today',
        hospitalName: 'Civil Hospital',
        district: 'Ahmedabad',
        verificationStatus: 'partially_verified',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoctorCard(doctor: doctor),
          ),
        ),
      );

      expect(find.text('Dr. Priya Mehta'), findsOneWidget);
      expect(find.text('Civil Hospital • Ahmedabad'), findsOneWidget);
      expect(find.text('Pending verification'), findsOneWidget);
      expect(find.byIcon(Icons.pending_outlined), findsOneWidget);
      expect(find.text('Verified'), findsNothing);
    });

    testWidgets('hides badge completely for unverified doctor', (tester) async {
      const doctor = Doctor(
        id: 'doc-unverified',
        name: 'Dr. Unverified Doe',
        specialty: 'Neurosurgery',
        distanceKm: 1.0,
        rating: 4.0,
        imageUrl: '',
        availability: 'Available Today',
        verificationStatus: 'unverified',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoctorCard(doctor: doctor),
          ),
        ),
      );

      expect(find.text('Dr. Unverified Doe'), findsOneWidget);
      expect(find.text('Verified'), findsNothing);
      expect(find.text('Pending verification'), findsNothing);
    });
  });
}
