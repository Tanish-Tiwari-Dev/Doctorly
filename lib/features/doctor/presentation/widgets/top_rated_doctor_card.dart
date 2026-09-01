import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';

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
    final theme = Theme.of(context);

    // --- Derived display strings (safe fallbacks) ---
    final String ratingStr =
        doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : '4.3';

    final String experienceStr = doctor.yearsOfExperience > 0
        ? 'EXP: ${doctor.yearsOfExperience} Y+'
        : 'EXP: 16 Y+';

    final String distanceStr = doctor.distanceKm > 0
        ? '${doctor.distanceKm.toStringAsFixed(1)} KM'
        : '2.5 KM';

    final String hoursStr =
        (doctor.openingTime.isNotEmpty && doctor.closingTime.isNotEmpty)
            ? '${doctor.openingTime} - ${doctor.closingTime}'
            : '10 AM - 10 PM';

    return GestureDetector(
      onTap: () => context.push('/doctor/${doctor.id}'),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
        decoration: BoxDecoration(
          color: DesignTokens.cardBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          boxShadow: const [DesignTokens.cardShadow],
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
                      color: DesignTokens.primaryLight,
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
                                  color: DesignTokens.primary,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 31.0,
                                color: DesignTokens.primary,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.sm + DesignTokens.xs),

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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.sm),
                          // Rating badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.sm,
                              vertical: DesignTokens.xs / 2,
                            ),
                            decoration: BoxDecoration(
                              color: DesignTokens.successBackground,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ratingStr,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: DesignTokens.success,
                                  ),
                                ),
                                const SizedBox(width: 2.0),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14.0,
                                  color: DesignTokens.starRating,
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
                            color: DesignTokens.textSecondary,
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            experienceStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10.0,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13.0,
                            color: DesignTokens.textSecondary,
                          ),
                          const SizedBox(width: 2.0),
                          Flexible(
                            child: Text(
                              distanceStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10.0,
                                color: DesignTokens.textSecondary,
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
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14.0,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: DesignTokens.xs),
                      Flexible(
                        child: Text(
                          hoursStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10.0,
                            color: DesignTokens.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: DesignTokens.sm),

                // Book Seat button
                ElevatedButton(
                  onPressed: () => context.push('/doctor/${doctor.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.sm + DesignTokens.xs,
                      vertical: DesignTokens.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 28.0),
                  ),
                  child: Text(
                    'Book Seat',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
