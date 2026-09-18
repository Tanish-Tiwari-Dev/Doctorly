import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:doctorly/features/doctor/data/repositories/reviews_repository.dart';
import 'package:doctorly/features/doctor/domain/models/doctor.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/features/doctor/presentation/widgets/leave_review_sheet.dart';
import 'package:doctorly/features/doctor/presentation/widgets/report_doctor_sheet.dart';
import 'package:doctorly/features/doctor/presentation/widgets/verified_badge.dart';
import 'package:doctorly/features/doctor/presentation/widgets/verified_explainer_sheet.dart';
import 'package:doctorly/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:doctorly/services/logger.dart';
import 'package:doctorly/utils/availability_checker.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/utils/disha_categories.dart';
import 'package:doctorly/utils/doctor_strings.dart';
import 'package:doctorly/widgets/max_width_container.dart';

/// Doctor profile screen with hero header, sticky bottom action bar (Call, WhatsApp, Directions),
/// professional facts row, 7-day OPD schedule, expertise chips, languages, directions,
/// collapsible "How we verify", and medical disclaimer footer.
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

  Future<void> _launchUrlAction(String urlString, String actionName) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not perform $actionName: $urlString'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    } catch (e, st) {
      LoggerService.instance.log.severe('Failed to launch $actionName: $urlString', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening link'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  void _callDoctor(Doctor doctor) {
    final phone = doctor.mobile ?? doctor.hospitalPhone;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(DoctorStrings.callUnavailable),
          backgroundColor: DesignTokens.textSecondary,
        ),
      );
      return;
    }
    _launchUrlAction('tel:$phone', 'phone call');
  }

  void _whatsappDoctor(Doctor doctor) {
    final wa = doctor.whatsapp ?? doctor.mobile;
    if (wa == null || wa.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(DoctorStrings.whatsappUnavailable),
          backgroundColor: DesignTokens.textSecondary,
        ),
      );
      return;
    }
    final cleanWa = wa.replaceAll(RegExp(r'[^0-9]'), '');
    _launchUrlAction('https://wa.me/$cleanWa', 'WhatsApp');
  }

  void _getDirections(Doctor doctor) {
    final destination = (doctor.address != null && doctor.address!.trim().isNotEmpty)
        ? doctor.address!
        : (doctor.hospitalName != null && doctor.hospitalName!.trim().isNotEmpty)
            ? doctor.hospitalName!
            : null;

    if (destination != null) {
      final encoded = Uri.encodeComponent(destination);
      _launchUrlAction('https://www.google.com/maps/search/?api=1&query=$encoded', 'Directions');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(DoctorStrings.directionsUnavailable),
          backgroundColor: DesignTokens.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorByIdProvider(widget.id));
    final theme = Theme.of(context);

    if (doctor == null) {
      return Scaffold(
        backgroundColor: DesignTokens.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.md),
          child: Shimmer.fromColors(
            baseColor: DesignTokens.divider,
            highlightColor: DesignTokens.cardBackground,
            child: Column(
              children: [
                const SizedBox(height: DesignTokens.md),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: DesignTokens.md),
                Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final favorites = ref.watch(favoritesProvider).valueOrNull ?? {};
    final isFav = favorites.contains(doctor.id);

    final bioText = (doctor.about != null && doctor.about!.trim().isNotEmpty)
        ? doctor.about!
        : '${doctor.name} is a specialist in ${doctor.specialty} at ${doctor.hospitalName ?? "leading medical facilities"}. Dedicated to clinical precision and patient recovery.';

    // Patient labels for active expertise / service categories
    final matchedCategoryTitles = <String>[];
    for (final category in dishaCategories) {
      if (category.serviceSlugs.isNotEmpty && doctorMatchesCategory(doctor, category.slug)) {
        matchedCategoryTitles.add(category.title);
      }
    }
    for (final entry in doctor.expertise.entries) {
      if (entry.value && !matchedCategoryTitles.contains(entry.key)) {
        matchedCategoryTitles.add(entry.key);
      }
    }

    // Availability status
    final availabilityInfo = calculateDoctorAvailability(
      opdDays: doctor.opdDays,
      opdOpen: doctor.opdOpen,
      opdClose: doctor.opdClose,
      opdByAppointment: doctor.opdByAppointment,
    );

    // Formatted teleconsultation status using tri-state helper
    final teleconsultStatusText = DoctorStrings.formatTriState(
      doctor.teleconsultationStatus,
      showText: DoctorStrings.teleconsultAvailable,
      hideText: DoctorStrings.teleconsultNotAvailable,
      fallbackText: DoctorStrings.teleconsultContact,
    );

    // Languages list
    final languagesList = doctor.languagesList.isNotEmpty
        ? doctor.languagesList
        : (doctor.languages != null && doctor.languages!.trim().isNotEmpty)
            ? doctor.languages!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
            : <String>[];

    // Contact availability checks for sticky action bar
    final hasPhone = (doctor.mobile != null && doctor.mobile!.trim().isNotEmpty) ||
        (doctor.hospitalPhone != null && doctor.hospitalPhone!.trim().isNotEmpty);
    final hasWhatsapp = (doctor.whatsapp != null && doctor.whatsapp!.trim().isNotEmpty) ||
        (doctor.mobile != null && doctor.mobile!.trim().isNotEmpty);
    final hasAddress = (doctor.address != null && doctor.address!.trim().isNotEmpty) ||
        (doctor.hospitalName != null && doctor.hospitalName!.trim().isNotEmpty);

    final isEmergency24x7 = doctor.emergency24x7.toLowerCase() == 'yes';

    return Scaffold(
      backgroundColor: DesignTokens.scaffoldBackground,
      body: MaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            // ── 1. Hero Header ──
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: DesignTokens.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
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
                    color: isFav ? DesignTokens.error : Colors.white,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(doctor.id),
                ),
                const SizedBox(width: DesignTokens.xs),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [DesignTokens.primary, DesignTokens.secondary],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Hero(
                          tag: 'doctor-avatar-${doctor.id}',
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: DesignTokens.avatarBackground,
                            ),
                            child: ClipOval(
                              child: doctor.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: doctor.imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: DesignTokens.textSecondary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: DesignTokens.textSecondary,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignTokens.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.md),
                          child: Text(
                            doctor.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.xs / 2),
                        Text(
                          doctor.qualification != null &&
                                  doctor.qualification!.isNotEmpty
                              ? '${doctor.specialty} • ${doctor.qualification}'
                              : doctor.specialty,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.xs),
                        if (doctor.isFullyVerified)
                          const VerifiedBadge(compact: true)
                        else if (doctor.isPartiallyVerified)
                          const VerifiedBadge(compact: true, partiallyVerified: true),
                        const SizedBox(height: DesignTokens.md),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 2. Accent 24x7 Emergency Banner (Only when emergency_24x7 == 'yes') ──
            if (isEmergency24x7)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  color: DesignTokens.errorBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.md,
                    vertical: DesignTokens.sm + DesignTokens.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.xs),
                        decoration: BoxDecoration(
                          color: DesignTokens.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency_rounded,
                          color: DesignTokens.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DoctorStrings.emergency24x7Banner,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: DesignTokens.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DoctorStrings.emergencySubtext,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: DesignTokens.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── 3. Facts Row (Experience | Today's OPD Status | Teleconsult) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.md, DesignTokens.md, DesignTokens.md, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _FactCard(
                        icon: Icons.work_history_rounded,
                        value: '${doctor.yearsOfExperience} yrs',
                        label: DoctorStrings.experienceLabel,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.sm),
                    Expanded(
                      child: _FactCard(
                        icon: Icons.access_time_rounded,
                        value: availabilityInfo.label,
                        label: DoctorStrings.opdStatusLabel,
                        valueColor: availabilityInfo.status == DoctorOpdStatus.openNow
                            ? DesignTokens.success
                            : availabilityInfo.status == DoctorOpdStatus.closedToday
                                ? DesignTokens.error
                                : DesignTokens.primary,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.sm),
                    Expanded(
                      child: _FactCard(
                        icon: Icons.video_camera_front_rounded,
                        value: teleconsultStatusText,
                        label: DoctorStrings.teleconsultLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 4. Main Details Sections ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional Details Card (Only rendered if fields exist)
                    if (_hasProfessionalDetails(doctor))
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DoctorStrings.professionalDetails, style: theme.textTheme.titleMedium),
                            const SizedBox(height: DesignTokens.sm),
                            if (doctor.hospitalName != null && doctor.hospitalName!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.business_rounded,
                                label: DoctorStrings.hospital,
                                value: doctor.hospitalName!,
                              ),
                            if (doctor.designation != null && doctor.designation!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.badge_outlined,
                                label: DoctorStrings.designation,
                                value: doctor.designation!,
                              ),
                            if (doctor.qualification != null && doctor.qualification!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.school_outlined,
                                label: DoctorStrings.qualification,
                                value: doctor.qualification!,
                              ),
                            if (doctor.subSpecialty != null && doctor.subSpecialty!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.medical_information_outlined,
                                label: DoctorStrings.subSpecialty,
                                value: doctor.subSpecialty!,
                              ),
                            if (doctor.district != null || doctor.city != null)
                              _DetailRow(
                                icon: Icons.location_on_outlined,
                                label: DoctorStrings.districtCity,
                                value: [doctor.district, doctor.city]
                                    .where((s) => s != null && s.trim().isNotEmpty)
                                    .join(', '),
                              ),
                          ],
                        ),
                      ),

                    if (_hasProfessionalDetails(doctor))
                      const SizedBox(height: DesignTokens.md),

                    // OPD Schedule Card with 7-day Chips
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DoctorStrings.opdSchedule, style: theme.textTheme.titleMedium),
                              if (doctor.opdByAppointment)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignTokens.sm,
                                    vertical: DesignTokens.xs / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.primaryLight,
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  ),
                                  child: Text(
                                    DoctorStrings.byAppointmentBadge,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: DesignTokens.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: DesignTokens.sm),
                          // 7 Day Chips Row
                          _OpdWeekChips(activeDays: doctor.opdDays),
                          const SizedBox(height: DesignTokens.sm),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: DoctorStrings.opdHours,
                            value: (doctor.opdOpen != null && doctor.opdClose != null)
                                ? '${doctor.opdOpen} - ${doctor.opdClose}'
                                : (doctor.openingTime.isNotEmpty && doctor.closingTime.isNotEmpty)
                                    ? '${doctor.openingTime} - ${doctor.closingTime}'
                                    : DoctorStrings.callToConfirmOpd,
                          ),
                          _DetailRow(
                            icon: Icons.event_available_outlined,
                            label: DoctorStrings.opdStatusLabel,
                            value: availabilityInfo.label,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Specialized Care (Expertise) Chips (Hidden if empty)
                    if (matchedCategoryTitles.isNotEmpty) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DoctorStrings.expertise, style: theme.textTheme.titleMedium),
                            const SizedBox(height: DesignTokens.sm),
                            Wrap(
                              spacing: DesignTokens.xs,
                              runSpacing: DesignTokens.xs,
                              children: matchedCategoryTitles.map((title) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignTokens.sm,
                                    vertical: DesignTokens.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.cardBackground,
                                    border: Border.all(color: DesignTokens.divider),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 14,
                                        color: DesignTokens.primary,
                                      ),
                                      const SizedBox(width: DesignTokens.xs),
                                      Text(
                                        title,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: DesignTokens.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                    ],

                    // Languages Spoken (Hidden if empty)
                    if (languagesList.isNotEmpty) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DoctorStrings.languages, style: theme.textTheme.titleMedium),
                            const SizedBox(height: DesignTokens.sm),
                            Wrap(
                              spacing: DesignTokens.xs,
                              runSpacing: DesignTokens.xs,
                              children: languagesList.map((lang) {
                                return Chip(
                                  label: Text(lang),
                                  backgroundColor: DesignTokens.scaffoldBackground,
                                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                                    color: DesignTokens.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                    side: const BorderSide(color: DesignTokens.divider),
                                  ),
                                  padding: EdgeInsets.zero,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                    ],

                    // About Doctor Card
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About Doctor', style: theme.textTheme.titleMedium),
                          const SizedBox(height: DesignTokens.sm),
                          Text(
                            bioText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: DesignTokens.textPrimary,
                              height: 1.5,
                            ),
                            maxLines: _isAboutExpanded ? null : 3,
                            overflow: _isAboutExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignTokens.xs),
                          GestureDetector(
                            onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                            child: Text(
                              _isAboutExpanded ? 'Show less' : 'Read more',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: DesignTokens.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Location & Directions Section
                    if (doctor.address != null || doctor.hospitalName != null) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DoctorStrings.location, style: theme.textTheme.titleMedium),
                            const SizedBox(height: DesignTokens.sm),
                            if (doctor.hospitalName != null)
                              Text(
                                doctor.hospitalName!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                            if (doctor.address != null && doctor.address!.trim().isNotEmpty) ...[
                              const SizedBox(height: DesignTokens.xs / 2),
                              Text(
                                doctor.address!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: DesignTokens.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: DesignTokens.sm),
                            OutlinedButton.icon(
                              onPressed: hasAddress ? () => _getDirections(doctor) : null,
                              icon: const Icon(Icons.directions_outlined, size: 16),
                              label: const Text('Get Directions'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DesignTokens.secondary,
                                side: const BorderSide(color: DesignTokens.secondary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                    ],

                    // Collapsible "How we verify" Expansion Card
                    _SectionCard(
                      child: Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.verified_user_outlined,
                            color: DesignTokens.primary,
                          ),
                          title: Text(
                            DoctorStrings.howWeVerify,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Registration & credential verification protocol',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DesignTokens.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          children: [
                            const SizedBox(height: DesignTokens.sm),
                            if (doctor.registrationNo != null && doctor.registrationNo!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.badge_outlined,
                                label: DoctorStrings.registration,
                                value: doctor.registrationNo!,
                              ),
                            if (doctor.councilName != null && doctor.councilName!.trim().isNotEmpty)
                              _DetailRow(
                                icon: Icons.account_balance_outlined,
                                label: DoctorStrings.council,
                                value: doctor.councilName!,
                              ),
                            if (doctor.registrationVerifiedOn != null || doctor.lastVerifiedAt != null)
                              _DetailRow(
                                icon: Icons.calendar_today_outlined,
                                label: DoctorStrings.verifiedOn,
                                value: doctor.registrationVerifiedOn ?? doctor.lastVerifiedAt ?? '',
                              ),
                            if (doctor.primarySourceUrl != null && doctor.primarySourceUrl!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: DesignTokens.xs),
                                child: InkWell(
                                  onTap: () => _launchUrlAction(doctor.primarySourceUrl!, 'Source'),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link_rounded, color: DesignTokens.primary, size: 16),
                                      const SizedBox(width: DesignTokens.sm),
                                      Expanded(
                                        child: Text(
                                          DoctorStrings.primarySource,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: DesignTokens.primary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (doctor.secondarySourceUrl != null && doctor.secondarySourceUrl!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: DesignTokens.xs),
                                child: InkWell(
                                  onTap: () => _launchUrlAction(doctor.secondarySourceUrl!, 'Secondary Source'),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.open_in_new_rounded, color: DesignTokens.secondary, size: 16),
                                      const SizedBox(width: DesignTokens.sm),
                                      Expanded(
                                        child: Text(
                                          DoctorStrings.secondarySource,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: DesignTokens.secondary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: DesignTokens.xs),
                            InkWell(
                              onTap: () => VerifiedExplainerSheet.show(context),
                              child: Text(
                                'Learn more about verification standards →',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: DesignTokens.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Reviews Section Card
                    _SectionCard(
                      child: _ReviewsSection(
                        doctorId: doctor.id,
                        doctorName: doctor.name,
                        doctorRating: doctor.rating,
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Medical Disclaimer Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.md),
                      decoration: BoxDecoration(
                        color: DesignTokens.scaffoldBackground,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        border: Border.all(color: DesignTokens.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: DesignTokens.textSecondary,
                              ),
                              const SizedBox(width: DesignTokens.xs),
                              Text(
                                DoctorStrings.disclaimerTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DesignTokens.xs),
                          Text(
                            DoctorStrings.disclaimerBody,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DesignTokens.textSecondary,
                              height: 1.5,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── 5. Sticky Bottom Action Bar (Call / WhatsApp / Directions) ──
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.md,
            vertical: DesignTokens.sm,
          ),
          decoration: const BoxDecoration(
            color: DesignTokens.cardBackground,
            border: Border(top: BorderSide(color: DesignTokens.divider, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Call Button
                  Expanded(
                    child: _StickyActionButton(
                      icon: Icons.phone_rounded,
                      label: DoctorStrings.call,
                      isEnabled: hasPhone,
                      color: DesignTokens.primary,
                      onPressed: () => _callDoctor(doctor),
                      disabledHelperText: DoctorStrings.callUnavailable,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.sm),
                  // WhatsApp Button
                  Expanded(
                    child: _StickyActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: DoctorStrings.whatsapp,
                      isEnabled: hasWhatsapp,
                      color: const Color(0xFF25D366),
                      onPressed: () => _whatsappDoctor(doctor),
                      disabledHelperText: DoctorStrings.whatsappUnavailable,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.sm),
                  // Directions Button
                  Expanded(
                    child: _StickyActionButton(
                      icon: Icons.directions_outlined,
                      label: DoctorStrings.directions,
                      isEnabled: hasAddress,
                      color: DesignTokens.secondary,
                      onPressed: () => _getDirections(doctor),
                      disabledHelperText: DoctorStrings.directionsUnavailable,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasProfessionalDetails(Doctor doctor) {
    return (doctor.hospitalName != null && doctor.hospitalName!.trim().isNotEmpty) ||
        (doctor.designation != null && doctor.designation!.trim().isNotEmpty) ||
        (doctor.qualification != null && doctor.qualification!.trim().isNotEmpty) ||
        (doctor.subSpecialty != null && doctor.subSpecialty!.trim().isNotEmpty) ||
        doctor.district != null ||
        doctor.city != null;
  }
}

/// Helper button for the sticky bottom bar with disabled helper text.
class _StickyActionButton extends StatelessWidget {
  const _StickyActionButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.color,
    required this.onPressed,
    required this.disabledHelperText,
  });

  final IconData icon;
  final String label;
  final bool isEnabled;
  final Color color;
  final VoidCallback onPressed;
  final String disabledHelperText;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return Tooltip(
        message: disabledHelperText,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(disabledHelperText),
                backgroundColor: DesignTokens.textSecondary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(icon, size: 16, color: DesignTokens.textSecondary),
          label: Text(
            label,
            style: const TextStyle(fontSize: 12, color: DesignTokens.textSecondary),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.scaffoldBackground,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              side: const BorderSide(color: DesignTokens.divider),
            ),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        ),
      ),
    );
  }
}

/// 7-day chips widget with today highlighted.
class _OpdWeekChips extends StatelessWidget {
  const _OpdWeekChips({required this.activeDays});

  final List<String> activeDays;

  static const List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // DateTime weekday: 1 = Monday, 7 = Sunday
    final todayIndex = now.weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayName = _daysOfWeek[index];
        final isToday = index == todayIndex;
        final isActive = activeDays.any(
          (d) => d.toLowerCase().startsWith(dayName.toLowerCase()),
        );

        Color chipBg;
        Color textColor;
        Border? border;

        if (isToday) {
          chipBg = isActive ? DesignTokens.primary : DesignTokens.scaffoldBackground;
          textColor = isActive ? Colors.white : DesignTokens.textPrimary;
          border = Border.all(
            color: DesignTokens.primary,
            width: 1.5,
          );
        } else if (isActive) {
          chipBg = DesignTokens.primaryLight;
          textColor = DesignTokens.primary;
          border = null;
        } else {
          chipBg = DesignTokens.scaffoldBackground;
          textColor = DesignTokens.textSecondary.withValues(alpha: 0.5);
          border = null;
        }

        return Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.xs),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: border,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : DesignTokens.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: DesignTokens.textSecondary),
          const SizedBox(width: DesignTokens.sm),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
      decoration: BoxDecoration(
        color: DesignTokens.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        boxShadow: const [DesignTokens.cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: DesignTokens.primary, size: 22),
          const SizedBox(height: DesignTokens.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? DesignTokens.textPrimary,
                  fontSize: 12,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                  fontSize: 10,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.cardBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        boxShadow: const [DesignTokens.cardShadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

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
                Text(DoctorStrings.reviews, style: theme.textTheme.titleMedium),
                const SizedBox(width: DesignTokens.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.sm,
                    vertical: DesignTokens.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.successBackground,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    '${doctorRating.toStringAsFixed(1)} ⭐',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.success,
                      fontWeight: FontWeight.w700,
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
                  color: DesignTokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.sm),
        reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text(
            'Could not load reviews.',
            style: theme.textTheme.bodySmall?.copyWith(color: DesignTokens.error),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: DesignTokens.md),
                child: Text(
                  'No reviews yet. Be the first to review $doctorName!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              );
            }
            final df = DateFormat('MMM d, yyyy');
            return Column(
              children: reviews.take(2).map((review) {
                return Container(
                  margin: const EdgeInsets.only(top: DesignTokens.sm),
                  padding: const EdgeInsets.all(DesignTokens.sm),
                  decoration: BoxDecoration(
                    color: DesignTokens.scaffoldBackground,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < review.rating ? Icons.star : Icons.star_border,
                                size: 14,
                                color: DesignTokens.starRating,
                              ),
                            ),
                          ),
                          Text(
                            df.format(review.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty) ...[
                        const SizedBox(height: DesignTokens.xs),
                        Text(
                          review.comment!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DesignTokens.textPrimary,
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
