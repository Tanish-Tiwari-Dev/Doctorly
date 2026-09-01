import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:doctorly/features/appointments/data/repositories/availability_repository.dart';
import 'package:doctorly/features/appointments/presentation/providers/appointments_provider.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/widgets/max_width_container.dart';

final availabilitySlotsProvider =
    FutureProvider.autoDispose.family<List<DateTime>, String>(
  (ref, doctorId) async {
    final repo = ref.watch(availabilityRepositoryProvider);
    return repo.fetchSlots(doctorId);
  },
);

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  DateTime? _selectedSlot;

  Future<void> _confirmBooking(BuildContext context, String doctorId) async {
    if (_selectedSlot == null) return;
    try {
      await ref
          .read(appointmentsProvider.notifier)
          .create(doctorId, _selectedSlot!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            content: Text(
              'Appointment confirmed successfully!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        );
        context.go('/appointments');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            ),
            content: Text(
              'Could not book appointment. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        );
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorByIdProvider(widget.doctorId));
    final slotsAsync = ref.watch(availabilitySlotsProvider(widget.doctorId));
    final submitting = ref.watch(appointmentsProvider).isLoading;
    final theme = Theme.of(context);

    if (doctor == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Book Appointment'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.md),
          child: Shimmer.fromColors(
            baseColor: DesignTokens.divider,
            highlightColor: DesignTokens.cardBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                ),
                const SizedBox(height: DesignTokens.lg),
                Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                  ),
                ),
                const SizedBox(height: DesignTokens.sm),
                Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: DesignTokens.xs / 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
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

    final canConfirm = _selectedSlot != null && !submitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Book Appointment',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: MaxWidthContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Doctor Mini-Profile (Top)
              Container(
                padding: const EdgeInsets.all(DesignTokens.sm + DesignTokens.xs),
                decoration: BoxDecoration(
                  color: DesignTokens.cardBackground,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  boxShadow: const [DesignTokens.cardShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1,
                        ),
                        color: AppColors.avatarBackground,
                      ),
                      child: ClipOval(
                        child: doctor.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: doctor.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: AppColors.textHint,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 24,
                                color: AppColors.textHint,
                              ),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.sm + DesignTokens.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doctor.specialty,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.lg),

              slotsAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.lg),
                  child: Shimmer.fromColors(
                    baseColor: DesignTokens.divider,
                    highlightColor: DesignTokens.cardBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall / 2),
                          ),
                        ),
                        const SizedBox(height: DesignTokens.sm),
                        Wrap(
                          spacing: DesignTokens.sm,
                          runSpacing: DesignTokens.sm,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.lg),
                  child: Center(
                    child: Text(
                      'Failed to load available appointment slots.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                data: (slots) {
                  if (slots.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: DesignTokens.xl),
                      child: Center(
                        child: Text(
                          'No available appointment slots at this time.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }

                  // Extract unique days
                  final uniqueDatesMap = <String, DateTime>{};
                  for (final slot in slots) {
                    final key = DateFormat('yyyy-MM-dd').format(slot);
                    if (!uniqueDatesMap.containsKey(key)) {
                      uniqueDatesMap[key] = DateTime(
                        slot.year,
                        slot.month,
                        slot.day,
                      );
                    }
                  }

                  final availableDates = uniqueDatesMap.values.toList()
                    ..sort((a, b) => a.compareTo(b));

                  // Auto-select initial date if none selected
                  if (_selectedDate == null && availableDates.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedDate = availableDates.first;
                        });
                      }
                    });
                  }

                  final activeDate = _selectedDate ?? availableDates.first;

                  // Filter slots for active selected date
                  final slotsForActiveDate = slots
                      .where((slot) => _isSameDay(slot, activeDate))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Date Selection (Horizontal Calendar)
                      Text(
                        'Select Date',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: DesignTokens.sm),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableDates.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: DesignTokens.sm),
                          itemBuilder: (context, index) {
                            final date = availableDates[index];
                            final isSelected = _isSameDay(date, activeDate);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                  // Clear selected slot if it doesn't belong to the new date
                                  if (_selectedSlot != null &&
                                      !_isSameDay(_selectedSlot!, date)) {
                                    _selectedSlot = null;
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : DesignTokens.cardBackground,
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [DesignTokens.cardShadow],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.9)
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: DesignTokens.xs),
                                    Text(
                                      DateFormat('d').format(date),
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: DesignTokens.xl),

                      // 4. Time Selection (Grid / Wrap)
                      Text(
                        'Available Time',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: DesignTokens.sm),
                      if (slotsForActiveDate.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: DesignTokens.md),
                          child: Text(
                            'No slots available on this date.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: DesignTokens.sm,
                          runSpacing: DesignTokens.sm,
                          children: slotsForActiveDate.map((slot) {
                            final isSelected = _selectedSlot == slot;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSlot = isSelected ? null : slot;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.md,
                                  vertical: DesignTokens.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : DesignTokens.inputBackground,
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  DateFormat('h:mm a').format(slot),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: DesignTokens.xl),
            ],
          ),
        ),
      ),

      // 5. Sticky Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.md),
          decoration: const BoxDecoration(
            color: DesignTokens.cardBackground,
            border: Border(
              top: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Selected Date & Time summary
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Slot',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedSlot != null
                          ? DateFormat('EEE, MMM d • h:mm a')
                              .format(_selectedSlot!)
                          : 'Select Date & Time',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedSlot != null
                            ? theme.colorScheme.primary
                            : AppColors.textHint,
                        fontWeight: _selectedSlot != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: DesignTokens.sm + DesignTokens.xs),

              // Right: Pill-shaped Confirm Button
              PressableScale(
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () => _confirmBooking(context, doctor.id)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    elevation: canConfirm ? 3 : 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.lg,
                      vertical: DesignTokens.sm + DesignTokens.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Confirm',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.scaleDown = 0.97,
  });

  final Widget child;
  final double scaleDown;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
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
