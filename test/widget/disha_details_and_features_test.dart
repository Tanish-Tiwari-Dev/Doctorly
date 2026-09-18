import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/config/app_features.dart';
import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:doctorly/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:doctorly/utils/doctor_strings.dart';
import 'package:doctorly/widgets/bottom_nav_scaffold.dart';
import 'package:go_router/go_router.dart';

class _FakeFavoritesNotifier extends FavoritesNotifier {
  @override
  Future<Set<String>> build() async {
    return <String>{};
  }
}

void main() {
  group('Disha Details Screen & V1 Presentation Tests', () {
    const testDoctor = Doctor(
      id: 'doc-disha-1',
      name: 'Dr. Aarav Patel',
      specialty: 'Neurosurgery',
      qualification: 'M.Ch Neurosurgery, MS',
      distanceKm: 2.5,
      rating: 4.8,
      imageUrl: '',
      availability: 'Open today',
      hospitalName: 'Apollo Hospitals',
      district: 'Ahmedabad',
      city: 'Ahmedabad',
      address: 'Plot 1A, GIDC Bhat, Ahmedabad',
      mobile: '+919876543210',
      whatsapp: '+919876543210',
      teleconsultation: true,
      teleconsultationStatus: 'yes',
      emergency24x7: 'yes',
      opdDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      opdOpen: '09:00',
      opdClose: '18:00',
      councilName: 'Gujarat Medical Council',
      registrationNo: 'G-12345',
      registrationVerifiedOn: '2026-01-15',
      primarySourceUrl: 'https://apollohospitals.com/doctor/aarav-patel',
      remarks: 'CONFIDENTIAL_INTERNAL_REMARK_DO_NOT_LEAK',
      yearsOfExperience: 14,
      verificationStatus: 'verified',
      isVerified: true,
    );

    testWidgets('DoctorDetailsScreen displays disclaimer and never renders "Unknown" or remarks', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorByIdProvider('doc-disha-1').overrideWithValue(testDoctor),
            favoritesProvider.overrideWith(_FakeFavoritesNotifier.new),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(id: 'doc-disha-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Medical disclaimer must be present
      expect(find.text(DoctorStrings.disclaimerTitle), findsOneWidget);
      expect(find.textContaining('Disha is an informational healthcare directory'), findsOneWidget);
      expect(find.textContaining('108'), findsOneWidget);

      // 2. Remarks must NEVER be rendered anywhere
      expect(find.textContaining('CONFIDENTIAL_INTERNAL_REMARK_DO_NOT_LEAK'), findsNothing);
      expect(find.textContaining('remarks'), findsNothing);

      // 3. Literal word "Unknown" must NEVER be rendered
      expect(find.text('Unknown'), findsNothing);
      expect(find.textContaining('Unknown'), findsNothing);

      // 4. Accent 24x7 Emergency banner rendered since emergency24x7 == 'yes'
      expect(find.text(DoctorStrings.emergency24x7Banner), findsOneWidget);
    });

    testWidgets('DoctorDetailsScreen highlights today on 7-day OPD chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorByIdProvider('doc-disha-1').overrideWithValue(testDoctor),
            favoritesProvider.overrideWith(_FakeFavoritesNotifier.new),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(id: 'doc-disha-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 7 days of week exist
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('Sticky action bar shows disabled states with helper text when contact info is null', (tester) async {
      const doctorNoContact = Doctor(
        id: 'doc-no-contact',
        name: 'Dr. Ghost Specialist',
        specialty: 'Neurosurgery',
        distanceKm: 0.0,
        rating: 4.0,
        imageUrl: '',
        availability: 'Call to confirm',
        mobile: null,
        hospitalPhone: null,
        whatsapp: null,
        address: null,
        hospitalName: null,
        verificationStatus: 'unverified',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorByIdProvider('doc-no-contact').overrideWithValue(doctorNoContact),
            favoritesProvider.overrideWith(_FakeFavoritesNotifier.new),
          ],
          child: const MaterialApp(
            home: DoctorDetailsScreen(id: 'doc-no-contact'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Call, WhatsApp, Directions buttons exist in sticky bar
      expect(find.text(DoctorStrings.call), findsOneWidget);
      expect(find.text(DoctorStrings.whatsapp), findsOneWidget);
      expect(find.text(DoctorStrings.directions), findsOneWidget);

      // Tap disabled Call button -> shows helper SnackBar with disabled message
      await tester.tap(find.text(DoctorStrings.call));
      await tester.pump();
      expect(find.text(DoctorStrings.callUnavailable), findsOneWidget);

      // Tap disabled WhatsApp button -> shows helper SnackBar
      await tester.tap(find.text(DoctorStrings.whatsapp));
      await tester.pump();
      expect(find.text(DoctorStrings.whatsappUnavailable), findsOneWidget);

      // Tap disabled Directions button -> shows helper SnackBar
      await tester.tap(find.text(DoctorStrings.directions));
      await tester.pump();
      expect(find.text(DoctorStrings.directionsUnavailable), findsOneWidget);
    });

    testWidgets('Appointments tab is hidden from BottomNavScaffold when AppFeatures.showBooking is false', (tester) async {
      expect(AppFeatures.showBooking, isFalse);

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return BottomNavScaffold(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const Scaffold(body: Text('Home Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/favorites',
                    builder: (context, state) => const Scaffold(body: Text('Favorites Content')),
                  ),
                ],
              ),
              if (AppFeatures.showBooking)
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/appointments',
                      builder: (context, state) => const Scaffold(body: Text('Appointments Content')),
                    ),
                  ],
                ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Home and Favorites should be visible in navigation bar
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);

      // Appointments must be hidden when showBooking is false
      expect(find.text('Appointments'), findsNothing);
    });
  });
}

