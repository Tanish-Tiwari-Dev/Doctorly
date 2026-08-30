import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/appointments_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/doctor_provider.dart';
import '../utils/app_colors.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key, required this.doctorId});
  final String doctorId;

  static const _timeSlots = <String>['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(bookingProvider).date ??
          DateTime(now.year, now.month, now.day + 1),
      firstDate: DateTime.now(),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      ref.read(bookingProvider.notifier).setDate(picked);
    }
  }

  Future<void> _confirmBooking(
    BuildContext context,
    WidgetRef ref,
    String doctorId,
  ) async {
    final booking = ref.read(bookingProvider);
    if (booking.date == null || booking.time == null) return;
    final scheduledFor = DateTime(
      booking.date!.year,
      booking.date!.month,
      booking.date!.day,
      booking.time!.hour,
      booking.time!.minute,
    );
    try {
      await ref
          .read(appointmentsProvider.notifier)
          .create(doctorId, scheduledFor);
      ref.read(bookingProvider.notifier).reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment confirmed!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
        context.go('/appointments');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not book. Try again.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorByIdProvider(doctorId));
    final booking = ref.watch(bookingProvider);
    final submitting = ref.watch(appointmentsProvider).isLoading;

    if (doctor == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final selectedDate = booking.date;
    final selectedTime = booking.time == null ? null : _formatTimeOfDay(booking.time!);
    final canConfirm = selectedDate != null && selectedTime != null && !submitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Book Appointment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.avatarBackground,
                    backgroundImage: doctor.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(doctor.imageUrl)
                        : null,
                    child: doctor.imageUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          doctor.specialty,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
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
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? DateFormat('EEE, MMM d').format(selectedDate)
                                : 'Choose a date',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((time) {
                      final selected = selectedTime == time;
                      return ChoiceChip(
                        label: Text(
                          time,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        selected: selected,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            ref.read(bookingProvider.notifier).setTime(
                                  TimeOfDay(
                                    hour: int.parse(time.split(':')[0]),
                                    minute: 0,
                                  ),
                                );
                          }
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: FilledButton(
            onPressed: canConfirm
                ? () => _confirmBooking(context, ref, doctor.id)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.5),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Confirm Booking',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
