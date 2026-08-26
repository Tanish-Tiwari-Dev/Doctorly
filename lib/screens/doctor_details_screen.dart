import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/doctor_provider.dart';

class DoctorDetailsScreen extends ConsumerWidget {
  const DoctorDetailsScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorByIdProvider(id));

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Doctor Details', style: GoogleFonts.inter()),
        ),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name, style: GoogleFonts.inter()),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  doctor.name,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor.rating}\u2605 \u2022 ${doctor.distanceKm.toStringAsFixed(1)} km away',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Availability', doctor.availability),
                _buildInfoRow('Consultation Fee', 'Free'),
                _buildInfoRow('Experience', '5+ years'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking feature coming soon!',
                    style: GoogleFonts.inter(),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Book Appointment',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600)),
          Text(value,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
