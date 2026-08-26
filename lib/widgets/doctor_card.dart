import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(doctor.imageUrl),
        ),
        title: Text(
          doctor.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          doctor.specialty,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${doctor.rating}\u2605',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            Text(
              '${doctor.distanceKm.toStringAsFixed(1)} km',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        onTap: () => context.go('/doctor/${doctor.id}'),
      ),
    );
  }
}
