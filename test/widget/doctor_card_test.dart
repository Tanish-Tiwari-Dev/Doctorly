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

    testWidgets(
        'renders longest dataset name and Pending verification badge at 320dp, 360dp, 412dp without overflow',
        (tester) async {
      const longestName = 'Dr Aadhya Sharma (Test 014)';
      const doctor = Doctor(
        id: 'TEST-DR-014',
        name: longestName,
        specialty: 'Neurointervention',
        distanceKm: 2.5,
        rating: 4.3,
        imageUrl: '',
        availability: 'Available Today',
        hospitalName: 'Demo Neuro Hospital 14',
        district: 'Kheda',
        verificationStatus: 'partially_verified',
      );

      const screenWidths = [320.0, 360.0, 412.0];

      for (final width in screenWidths) {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DoctorCard(doctor: doctor),
            ),
          ),
        );

        // Assert no RenderFlex overflow exception
        expect(tester.takeException(), isNull);

        // Assert name text is present in the widget tree
        final nameFinder = find.text(longestName);
        expect(nameFinder, findsOneWidget);

        // Assert badge text is present
        final badgeFinder = find.text('Pending verification');
        expect(badgeFinder, findsOneWidget);

        // Assert badge row is a sibling BELOW the name, not inside the same Row
        final nameWidget = tester.firstWidget<Text>(nameFinder);
        expect(nameWidget.maxLines, 2);

        // Check vertical positioning: badge is rendered below the name
        final nameBottom = tester.getBottomLeft(nameFinder).dy;
        final badgeTop = tester.getTopLeft(badgeFinder).dy;
        expect(badgeTop, greaterThanOrEqualTo(nameBottom));

        // Ensure "View Profile" button and OPD chip are present without overflow
        expect(find.text('View Profile'), findsOneWidget);
      }
    });
  });
}
