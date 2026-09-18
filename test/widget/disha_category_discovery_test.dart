import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_filter_provider.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/screens/home_screen.dart';
import 'package:doctorly/features/doctor/presentation/widgets/category_explainer_sheet.dart';
import 'package:doctorly/utils/doctor_strings.dart';


class _FakeDoctorsNotifier extends DoctorsNotifier {
  _FakeDoctorsNotifier(this._doctors);
  final List<Doctor> _doctors;

  @override
  Future<List<Doctor>> build() async => _doctors;
}

void main() {
  group('Disha Patient-Facing Category Discovery Widget Tests', () {
    const doctorTraumaAhmedabad = Doctor(
      id: 'doc-trauma-ahmedabad',
      name: 'Dr. Trauma Specialist',
      specialty: 'Neurosurgery',
      distanceKm: 2.0,
      rating: 4.8,
      imageUrl: '',
      availability: 'Open today',
      district: 'Ahmedabad',
      hospitalName: 'Civil Hospital',
      serviceStatuses: {
        'trauma': 'yes',
      },
    );

    const doctorSpineAhmedabad = Doctor(
      id: 'doc-spine-ahmedabad',
      name: 'Dr. Spine Specialist',
      specialty: 'Neurosurgery',
      distanceKm: 3.0,
      rating: 4.9,
      imageUrl: '',
      availability: 'Open today',
      district: 'Ahmedabad',
      hospitalName: 'Apollo Hospitals',
      serviceStatuses: {
        'spine': 'yes',
      },
    );

    const doctorTraumaSurat = Doctor(
      id: 'doc-trauma-surat',
      name: 'Dr. Surat Trauma Surgeon',
      specialty: 'Neurosurgery',
      distanceKm: 200.0,
      rating: 4.7,
      imageUrl: '',
      availability: 'Open today',
      district: 'Surat',
      hospitalName: 'Surat Civil Hospital',
      serviceStatuses: {
        'trauma': 'yes',
      },
    );

    final allTestDoctors = [
      doctorTraumaAhmedabad,
      doctorSpineAhmedabad,
      doctorTraumaSurat,
    ];

    testWidgets('Renders all 8 Disha category chips with labels and info icons above search bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorListProvider.overrideWith(() => _FakeDoctorsNotifier(allTestDoctors)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Section title
      expect(find.text(DoctorStrings.categorySectionTitle), findsOneWidget);

      // Verify category chips exist
      expect(find.text(DoctorStrings.catTraumaTitle), findsOneWidget);
      expect(find.text(DoctorStrings.catBrainTumorTitle), findsOneWidget);
      expect(find.text(DoctorStrings.catSpineTitle), findsOneWidget);

      // Verify info icons exist on category chips
      expect(find.byIcon(Icons.info_outline_rounded), findsWidgets);
    });

    testWidgets('Tapping a category chip filters the doctor listing via doctorMatchesCategory', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorListProvider.overrideWith(() => _FakeDoctorsNotifier(allTestDoctors)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially all doctors in the listing appear
      expect(find.text('Dr. Trauma Specialist'), findsOneWidget);
      expect(find.text('Dr. Spine Specialist'), findsOneWidget);
      expect(find.text('Dr. Surat Trauma Surgeon'), findsOneWidget);

      // Tap "Brain & Spine Trauma" category chip
      await tester.tap(find.text(DoctorStrings.catTraumaTitle));
      await tester.pumpAndSettle();

      // Only trauma doctors match
      expect(find.text('Dr. Trauma Specialist'), findsOneWidget);
      expect(find.text('Dr. Surat Trauma Surgeon'), findsOneWidget);
      expect(find.text('Dr. Spine Specialist'), findsNothing);

      // Tap "Spine Care" category chip
      await tester.tap(find.text(DoctorStrings.catSpineTitle));
      await tester.pumpAndSettle();

      // Only spine doctors match
      expect(find.text('Dr. Spine Specialist'), findsOneWidget);
      expect(find.text('Dr. Trauma Specialist'), findsNothing);
      expect(find.text('Dr. Surat Trauma Surgeon'), findsNothing);
    });

    testWidgets('Tapping category info icon opens CategoryExplainerSheet with plain-language copy & disclaimer', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorListProvider.overrideWith(() => _FakeDoctorsNotifier(allTestDoctors)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the info icon tooltip for Trauma
      final infoFinder = find.byTooltip('About ${DoctorStrings.catTraumaTitle}');
      expect(infoFinder, findsOneWidget);

      await tester.tap(infoFinder);
      await tester.pumpAndSettle();

      // Explainer sheet is opened
      expect(find.byType(CategoryExplainerSheet), findsOneWidget);
      expect(find.text(DoctorStrings.categoryExplainerTitle), findsOneWidget);
      expect(find.text(DoctorStrings.catTraumaTitle), findsWidgets);
      expect(find.text(DoctorStrings.categoryWhatIsThis), findsOneWidget);
      expect(find.text(DoctorStrings.catTraumaDesc), findsOneWidget);
      expect(find.text(DoctorStrings.categoryWhenNeeded), findsOneWidget);
      expect(find.text(DoctorStrings.catTraumaWhen), findsOneWidget);

      // Must end with medical disclaimer string
      expect(find.text(DoctorStrings.disclaimerBody), findsOneWidget);

      // Scroll to Understood button if needed and tap to dismiss
      final understoodButton = find.text('Understood');
      await tester.ensureVisible(understoodButton);
      await tester.tap(understoodButton);
      await tester.pumpAndSettle();
      expect(find.byType(CategoryExplainerSheet), findsNothing);
    });


    testWidgets('Combines category filter with district filter and shows custom empty state when no match', (tester) async {
      final container = ProviderContainer(
        overrides: [
          doctorListProvider.overrideWith(() => _FakeDoctorsNotifier(allTestDoctors)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set district filter to "Surat"
      container.read(doctorFilterProvider.notifier).setDistrict('Surat');
      await tester.pumpAndSettle();

      // Currently shows Dr. Surat Trauma Surgeon
      expect(find.text('Dr. Surat Trauma Surgeon'), findsOneWidget);
      expect(find.text('Dr. Trauma Specialist'), findsNothing);
      expect(find.text('Dr. Spine Specialist'), findsNothing);

      // Select "Spine Care" category chip (which has NO doctors in Surat)
      await tester.tap(find.text(DoctorStrings.catSpineTitle));
      await tester.pumpAndSettle();

      // Empty state rendered with custom district & category message
      expect(find.text('No doctors found'), findsOneWidget);
      expect(
        find.textContaining('No specialists found for this category in Surat'),
        findsOneWidget,
      );

      // Switch back to "Brain & Spine Trauma"
      await tester.tap(find.text(DoctorStrings.catTraumaTitle));
      await tester.pumpAndSettle();

      // Now Dr. Surat Trauma Surgeon appears again
      expect(find.text('Dr. Surat Trauma Surgeon'), findsOneWidget);
    });
  });
}
