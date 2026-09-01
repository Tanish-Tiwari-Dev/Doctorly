import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:doctorly/features/doctor/data/repositories/reviews_repository.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/widgets/leave_review_sheet.dart';
import 'package:doctorly/features/doctor/presentation/widgets/report_doctor_sheet.dart';
import 'package:doctorly/features/doctor/presentation/widgets/top_rated_doctor_card.dart';
import 'package:doctorly/features/doctor/presentation/widgets/verified_badge.dart';
import 'package:doctorly/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/widgets/max_width_container.dart';

/// Premium doctor profile screen with gradient hero, stats, and booking bar.
class DoctorDetailsScreen extends ConsumerStatefulWidget {
  /// Creates a [DoctorDetailsScreen] for the given doctor [id].
  const DoctorDetailsScreen({super.key, required this.id});

  /// The doctor's unique identifier.
  final String id;

  @override
  ConsumerState<DoctorDetailsScreen> createState() =>
      _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends ConsumerState<DoctorDetailsScreen> {
  bool _isAboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorByIdProvider(widget.id));
    final theme = Theme.of(context);

    if (doctor == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final favorites =
        ref.watch(favoritesProvider).valueOrNull ?? <String>{};
    final isFav = favorites.contains(widget.id);

    Future<void> toggleFavorite() async {
      try {
        await ref.read(favoritesProvider.notifier).toggle(doctor.id);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not update favorite. Try again.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          );
        }
      }
    }

    final activeExpertise = doctor.expertise.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final bioText = doctor.about ??
        (doctor.designation != null && doctor.hospitalName != null
            ? '${doctor.designation} at ${doctor.hospitalName}. Experienced specialist dedicated to providing top-notch, empathetic medical care with a track record of excellent patient outcomes and modern diagnostic procedures.'
            : doctor.designation ??
                doctor.hospitalName ??
                'Experienced ${doctor.specialty} dedicated to providing top-notch medical care, comprehensive diagnoses, and personalized treatment plans for every patient.');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: MaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            // ── 1. Hero Header SliverAppBar ──
            SliverAppBar(
              expandedHeight: 320.0,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0A7E8C),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.flag_outlined, color: Colors.white),
                  tooltip: 'Report Doctor',
                  onPressed: () => ReportDoctorSheet.show(
                    context,
                    doctorId: doctor.id,
                    doctorName: doctor.name,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : Colors.white,
                  ),
                  onPressed: toggleFavorite,
                ),
                const SizedBox(width: DesignTokens.xs),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A7E8C), Color(0xFF14B8C4)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Avatar
                        Hero(
                          tag: 'doctor-avatar-${doctor.id}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 4),
                              color: AppColors.avatarBackground,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: doctor.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: doctor.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => const Icon(
                                        Icons.person,
                                        size: 52,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 52,
                                      color: Color(0xFF9CA3AF),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.md),
                          child: Text(
                            doctor.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Specialty
                        Text(
                          doctor.qualification != null &&
                                  doctor.qualification!.isNotEmpty
                              ? '${doctor.specialty} • ${doctor.qualification}'
                              : doctor.specialty,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (doctor.isVerified) ...[
                          const SizedBox(height: 8),
                          const VerifiedBadge(compact: true),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 2. Quick Stats Row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.md, DesignTokens.lg, DesignTokens.md, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_alt_rounded,
                        value: '1.2k+',
                        label: 'Patients',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.work_history_rounded,
                        value: '${doctor.yearsOfExperience} yrs',
                        label: 'Experience',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        value: doctor.rating.toStringAsFixed(1),
                        label: 'Rating',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 3. Content Sheet ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: DesignTokens.lg),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: DesignTokens.lg),

                      // ── About Doctor Card ──
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('About Doctor',
                                    style: theme.textTheme.titleLarge),
                                if (doctor.isAvailableToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius:
                                          BorderRadius.circular(
                                              DesignTokens.small),
                                    ),
                                    child: Text(
                                      'Available Today',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: const Color(0xFF047857),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.sm),
                            Text(
                              bioText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF374151),
                                height: 1.6,
                              ),
                              maxLines:
                                  _isAboutExpanded ? null : 3,
                              overflow: _isAboutExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _isAboutExpanded =
                                      !_isAboutExpanded),
                              child: Text(
                                _isAboutExpanded
                                    ? 'Show less'
                                    : 'Read more',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (activeExpertise.isNotEmpty) ...[
                              const SizedBox(height: DesignTokens.md),
                              Text('Expertise',
                                  style:
                                      theme.textTheme.titleLarge
                                          ?.copyWith(fontSize: 16)),
                              const SizedBox(height: DesignTokens.xs),
                              ...activeExpertise.map((item) =>
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .check_circle_outline,
                                            color: theme.colorScheme
                                                .primary,
                                            size: 18),
                                        const SizedBox(
                                            width:
                                                DesignTokens.sm),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: theme.textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: const Color(
                                                  0xFF374151),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Reviews Section Card ──
                      _SectionCard(
                        child: _ReviewsSection(
                          doctorId: doctor.id,
                          doctorName: doctor.name,
                          doctorRating: doctor.rating,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Recommended Doctors Section ──
                      _SectionCard(
                        child: _RecommendedDoctorsSection(
                          currentDoctorId: doctor.id,
                          specialty: doctor.specialty,
                        ),
                      ),

                      const SizedBox(height: DesignTokens.xl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── 5. Sticky Bottom Bar ──
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.md),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Fee',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$50',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _PressableScale(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/booking/${doctor.id}'),
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 20),
                    label: Text(
                      'Book Appointment',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0x330A7E8C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Individual stat card (Patients / Experience / Rating).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.medium),
        boxShadow: const [DesignTokens.cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Reusable white card wrapper for content sections.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.medium),
        boxShadow: const [DesignTokens.cardShadow],
      ),
      child: child,
    );
  }
}

/// Reviews section with empty-state placeholder and top-2 reviews.
class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({
    required this.doctorId,
    required this.doctorName,
    required this.doctorRating,
  });

  final String doctorId;
  final String doctorName;
  final double doctorRating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(doctorReviewsProvider(doctorId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Reviews', style: theme.textTheme.titleLarge),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${doctorRating.toStringAsFixed(1)} ⭐',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => LeaveReviewSheet.show(
                context,
                doctorId: doctorId,
                doctorName: doctorName,
              ),
              child: Text(
                'Leave Review',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Could not load reviews.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: DesignTokens.lg),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 48,
                          color: AppColors.primary
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text(
                        'No reviews yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to review $doctorName!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            final df = DateFormat('MMM d, yyyy');
            final topReviews = reviews.take(2).toList();
            return Column(
              children: topReviews.map((review) {
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE5E7EB),
                            ),
                            child: const Icon(Icons.person,
                                size: 22,
                                color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verified Patient',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5,
                                      (starIndex) {
                                    final isFilled =
                                        starIndex < review.rating;
                                    return Icon(
                                      isFilled
                                          ? Icons.star_rounded
                                          : Icons
                                              .star_outline_rounded,
                                      color: isFilled
                                          ? AppColors.warning
                                          : AppColors.inactiveIcon,
                                      size: 14,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            df.format(
                                review.createdAt.toLocal()),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null &&
                          review.comment!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          review.comment!,
                          style:
                              theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Recommended doctors horizontal carousel using [TopRatedDoctorCard].
class _RecommendedDoctorsSection extends ConsumerWidget {
  const _RecommendedDoctorsSection({
    required this.currentDoctorId,
    required this.specialty,
  });

  final String currentDoctorId;
  final String specialty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAsync = ref.watch(
      similarDoctorsProvider((
        doctorId: currentDoctorId,
        specialty: specialty,
      )),
    );
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended Doctors', style: theme.textTheme.titleLarge),
        const SizedBox(height: DesignTokens.sm),
        similarAsync.when(
          loading: () => const SizedBox(
            height: 140,
            child: Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (err, _) => Padding(
            padding:
                const EdgeInsets.symmetric(vertical: DesignTokens.sm),
            child: Text(
              'Could not load recommended doctors.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ),
          data: (doctors) {
            if (doctors.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.sm),
                child: Text(
                  'No other $specialty doctors found.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: DesignTokens.sm),
                itemBuilder: (context, index) =>
                    TopRatedDoctorCard(doctor: doctors[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Micro-interaction: scale-down on press for the booking button.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, this.scaleDown = 0.97});

  final Widget child;
  final double scaleDown;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
