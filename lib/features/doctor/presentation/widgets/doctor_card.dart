import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';

/// A card widget displaying doctor information matching exact Figma layout specifications.
class DoctorCard extends StatelessWidget {
  /// Creates a [DoctorCard] instance.
  const DoctorCard({
    super.key,
    required this.doctor,
    this.compact = false,
  });

  /// The doctor domain model.
  final Doctor doctor;

  /// Whether compact margin should be used (e.g. inside carousel).
  final bool compact;

  /// Generates hero tag for navigation animations.
  static String heroTag(String doctorId) => 'doctor-avatar-$doctorId';

  @override
  Widget build(BuildContext context) {
    final String ratingStr =
        doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '4.3';

    final String experienceStr = doctor.yearsOfExperience > 0
        ? 'EXP: ${doctor.yearsOfExperience} Y+'
        : 'EXP: 16 Y+';

    final String distanceStr = doctor.distanceKm > 0
        ? '${doctor.distanceKm.toStringAsFixed(1)} KM'
        : '2.5 KM';

    final String addressStr = (doctor.address != null && doctor.address!.isNotEmpty)
        ? doctor.address!
        : '123 Colony, Yerwada';

    final String hoursStr =
        (doctor.openingTime.isNotEmpty && doctor.closingTime.isNotEmpty)
            ? '${doctor.openingTime} - ${doctor.closingTime}'
            : '10 AM - 10 PM';

    return GestureDetector(
      onTap: () => context.push('/doctor/${doctor.id}'),
      child: Container(
        margin: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side (Avatar)
            Container(
              width: 60.0,
              height: 60.0,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F7F8),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: doctor.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: doctor.imageUrl,
                        width: 60.0,
                        height: 60.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 31.0,
                            color: Color(0xFF0A7E8C),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 31.0,
                          color: Color(0xFF0A7E8C),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Middle Content (Expanded Column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A. Top Row (Name + Rating)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ratingStr,
                              style: GoogleFonts.inter(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            const Icon(
                              Icons.star_rounded,
                              size: 14.0,
                              color: Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // B. Stats Row (Experience, Distance, Address)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 14.0,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        experienceStr,
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14.0,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        distanceStr,
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Icon(
                        Icons.location_city_outlined,
                        size: 14.0,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          addressStr,
                          style: GoogleFonts.inter(
                            fontSize: 10.0,
                            color: const Color(0xFF4B5563),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // C. Hours & Book Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14.0,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            hoursStr,
                            style: GoogleFonts.inter(
                              fontSize: 10.0,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/doctor/${doctor.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                          minimumSize: const Size(0, 28.0),
                        ),
                        child: Text(
                          'Book Seat',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



