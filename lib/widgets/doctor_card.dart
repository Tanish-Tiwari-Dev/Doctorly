import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/doctor.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_colors.dart';

class DoctorCard extends ConsumerWidget {
  const DoctorCard({super.key, required this.doctor, this.compact = false});

  final Doctor doctor;
  final bool compact;

  static String heroTag(String doctorId) => 'doctor-details-$doctorId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider).valueOrNull ?? <String>{};
    final isFav = favorites.contains(doctor.id);
    final theme = Theme.of(context);

    return Container(
      margin: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/doctor/${doctor.id}'),
          child: Padding(
            padding: EdgeInsets.all(compact ? 8.0 : 12.0),
            child: Row(
              children: [
                if (!compact)
                  Hero(
                    tag: heroTag(doctor.id),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: doctor.imageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(doctor.imageUrl)
                          : null,
                      backgroundColor: AppColors.avatarBackground,
                    ),
                  ),
                if (compact)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: doctor.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(doctor.imageUrl)
                        : null,
                    backgroundColor: AppColors.avatarBackground,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        doctor.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.specialty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (doctor.isAvailableToday)
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 4,
                              backgroundColor: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Available Today',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.distanceKm.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? AppColors.error
                              : AppColors.inactiveFavorite,
                          size: 22,
                        ),
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(doctor.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
