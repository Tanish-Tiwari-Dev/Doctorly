import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/doctor_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/doctor_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _handleNearMe(BuildContext context, WidgetRef ref) async {
    try {
      final bool granted =
          await ref.read(locationServiceProvider).requestPermission();

      if (!context.mounted) return;

      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nearby doctors sorted by distance.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location denied, showing default nearby doctors.',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location denied, showing default nearby doctors.',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(sortedDoctorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctorly',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me),
            tooltip: 'Near Me',
            onPressed: () => _handleNearMe(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties...',
                hintStyle: GoogleFonts.inter(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(doctor: doctor);
                    },
                  );
                }

                final int crossAxisCount =
                    (constraints.maxWidth / 300).floor().clamp(2, 4);

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(doctor: doctor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
