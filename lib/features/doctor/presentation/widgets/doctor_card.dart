import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/widgets/verified_badge.dart';
import 'package:doctorly/utils/availability_checker.dart';
import 'package:doctorly/utils/design_tokens.dart';

/// A card widget displaying doctor information with hospital and district/city details,
/// verification badges, and an OPD availability status pill.
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

    // Rich OPD availability calculation
    final availabilityInfo = calculateDoctorAvailability(
      opdDays: doctor.opdDays,
      opdOpen: doctor.opdOpen ?? doctor.openingTime,
      opdClose: doctor.opdClose ?? doctor.closingTime,
      opdByAppointment: doctor.opdByAppointment,
    );

    // Color and icon for OPD pill
    final Color opdColor;
    final Color opdBackground;
    final IconData opdIcon;

    switch (availabilityInfo.status) {
      case DoctorOpdStatus.openNow:
        opdColor = DesignTokens.success;
        opdBackground = DesignTokens.successBackground;
        opdIcon = Icons.check_circle_outline_rounded;
      case DoctorOpdStatus.opensAt:
        opdColor = DesignTokens.primary;
        opdBackground = DesignTokens.primaryLight;
        opdIcon = Icons.access_time_rounded;
      case DoctorOpdStatus.byAppointmentOnly:
        opdColor = DesignTokens.secondary;
        opdBackground = DesignTokens.primaryLight;
        opdIcon = Icons.calendar_month_outlined;
      case DoctorOpdStatus.closedToday:
        opdColor = DesignTokens.error;
        opdBackground = DesignTokens.errorBackground;
        opdIcon = Icons.do_not_disturb_on_outlined;
      case DoctorOpdStatus.callToConfirm:
        opdColor = DesignTokens.textSecondary;
        opdBackground = DesignTokens.inputBackground;
        opdIcon = Icons.phone_outlined;
    }

    // Hospital + City / District line
    final String locationLine = [
      if (doctor.hospitalName != null && doctor.hospitalName!.isNotEmpty)
        doctor.hospitalName!,
      if (doctor.district != null && doctor.district!.isNotEmpty)
        doctor.district!
      else if (doctor.city != null && doctor.city!.isNotEmpty)
        doctor.city!
      else if (doctor.address != null && doctor.address!.isNotEmpty)
        doctor.address!,
    ].join(' • ');

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
                  // A. Top Row (Name + Verification + Rating)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
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
                            if (doctor.isFullyVerified) ...[
                              const SizedBox(width: DesignTokens.xs),
                              const VerifiedBadge(compact: true),
                            ] else if (doctor.isPartiallyVerified) ...[
                              const SizedBox(width: DesignTokens.xs),
                              const VerifiedBadge(compact: true, partiallyVerified: true),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.xs),
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

                  // Hospital + District / City line
                  if (locationLine.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.xs / 2),
                    Text(
                      locationLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: DesignTokens.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: DesignTokens.xs),

                  // B. Stats Row (Experience, Distance)
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
                    ],
                  ),
                  const SizedBox(height: DesignTokens.sm),

                  // C. OPD Availability Pill & View Profile Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.sm,
                            vertical: DesignTokens.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: opdBackground,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                opdIcon,
                                size: 13.0,
                                color: opdColor,
                              ),
                              const SizedBox(width: DesignTokens.xs),
                              Flexible(
                                child: Text(
                                  availabilityInfo.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: opdColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.xs),
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
                          'View Profile',
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
