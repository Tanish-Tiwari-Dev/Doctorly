import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/utils/design_tokens.dart';

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
    final theme = Theme.of(context);

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
            : const EdgeInsets.symmetric(
                horizontal: DesignTokens.md,
                vertical: DesignTokens.sm,
              ),
        padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
        decoration: BoxDecoration(
          color: DesignTokens.cardBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          boxShadow: const [DesignTokens.cardShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side (Avatar)
            Container(
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
                        errorWidget: (context, url, error) => const Center(
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
            const SizedBox(width: DesignTokens.sm + DesignTokens.xs),

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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.sm,
                          vertical: DesignTokens.xs,
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
                                fontSize: 10.0,
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
                  const SizedBox(height: DesignTokens.sm),

                  // B. Stats Row (Experience, Distance, Address)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.work_outline,
                        size: 14.0,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: DesignTokens.xs),
                      Text(
                        experienceStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.0,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14.0,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: DesignTokens.xs),
                      Text(
                        distanceStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.0,
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                      const Icon(
                        Icons.location_city_outlined,
                        size: 14.0,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: DesignTokens.xs),
                      Expanded(
                        child: Text(
                          addressStr,
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
                            color: DesignTokens.textSecondary,
                          ),
                          const SizedBox(width: DesignTokens.xs),
                          Text(
                            hoursStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10.0,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/doctor/${doctor.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.md,
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
                            fontSize: 12.0,
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
          ],
        ),
      ),
    );
  }
}
