import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';

/// A compact card for the "Top Rated" horizontal carousel on the Home Screen.
///
/// Displays doctor avatar, name, rating badge, experience/distance/address
/// stats row, and a bottom row with operating hours and a "Book Seat" button.
/// Design mirrors the main [DoctorCard] layout in a carousel-friendly width.
class TopRatedDoctorCard extends StatelessWidget {
  /// Creates a [TopRatedDoctorCard] instance.
  const TopRatedDoctorCard({super.key, required this.doctor});

  /// The doctor domain model to display.
  final Doctor doctor;

  /// Generates a Hero animation tag for smooth transitions.
  static String heroTag(String doctorId) => 'top-rated-avatar-$doctorId';

  @override
  Widget build(BuildContext context) {
    // --- Derived display strings (safe fallbacks) ---
    final String ratingStr =
        doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '4.3';

    final String experienceStr = doctor.yearsOfExperience > 0
        ? 'EXP: ${doctor.yearsOfExperience} Y+'
        : 'EXP: 16 Y+';

    final String distanceStr = doctor.distanceKm > 0
        ? '${doctor.distanceKm.toStringAsFixed(1)} KM'
        : '2.5 KM';

    final String addressStr =
        (doctor.address != null && doctor.address!.isNotEmpty)
            ? doctor.address!
            : '123 Colony, Yerwada';

    final String hoursStr =
        (doctor.openingTime.isNotEmpty && doctor.closingTime.isNotEmpty)
            ? '${doctor.openingTime} - ${doctor.closingTime}'
            : '10 AM - 10 PM';

    return GestureDetector(
      onTap: () => context.push('/doctor/${doctor.id}'),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Section: Avatar + Name/Rating ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Hero(
                  tag: heroTag(doctor.id),
                  child: Container(
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
                              errorWidget: (context, url, error) =>
                                  const Center(
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
                ),
                const SizedBox(width: 12.0),

                // Name + Specialty + Rating badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with rating badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: GoogleFonts.inter(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Rating badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
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
                                    fontSize: 11.0,
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
                      const SizedBox(height: 6.0),

                      // Stats row: Experience · Distance · Address
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 13.0,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            experienceStr,
                            style: GoogleFonts.inter(
                              fontSize: 10.0,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13.0,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            distanceStr,
                            style: GoogleFonts.inter(
                              fontSize: 10.0,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.location_city_outlined,
                            size: 13.0,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 3.0),
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
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // ── Bottom Section: Hours + Book Seat button ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Operating hours
                Row(
                  mainAxisSize: MainAxisSize.min,
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

                // Book Seat button
                ElevatedButton(
                  onPressed: () => context.push('/doctor/${doctor.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
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
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
