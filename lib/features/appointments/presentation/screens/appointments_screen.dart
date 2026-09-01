import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:doctorly/features/appointments/domain/models/appointment.dart';
import 'package:doctorly/features/appointments/presentation/providers/appointments_provider.dart';
import 'package:doctorly/features/appointments/presentation/widgets/appointment_card_skeleton.dart';
import 'package:doctorly/features/doctor/presentation/providers/doctor_provider.dart';
import 'package:doctorly/utils/app_colors.dart';
import 'package:doctorly/utils/design_tokens.dart';
import 'package:doctorly/widgets/empty_state.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: false,
      ),
      body: appointments.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm),
          itemCount: 4,
          itemBuilder: (context, index) => const AppointmentCardSkeleton(),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load appointments',
          subtitle: 'Please check your connection and try again.',
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy,
              title: 'No appointments yet.',
              subtitle: "Book your first appointment from a doctor's profile.",
            );
          }
          final df = DateFormat('EEE, MMM d • h:mm a');
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.sm),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: DesignTokens.xs),
            itemBuilder: (context, index) {
              final appt = items[index];
              final doctor = ref.watch(doctorByIdProvider(appt.doctorId));
              return _AppointmentCard(
                appointment: appt,
                doctorName: doctor?.name ?? 'Unknown doctor',
                specialty: doctor?.specialty ?? '',
                formattedDate: df.format(appt.scheduledFor.toLocal()),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends ConsumerStatefulWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.doctorName,
    required this.specialty,
    required this.formattedDate,
  });

  final Appointment appointment;
  final String doctorName;
  final String specialty;
  final String formattedDate;

  @override
  ConsumerState<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends ConsumerState<_AppointmentCard> {
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    setState(() {
      _isCancelling = true;
    });
    try {
      await ref
          .read(appointmentsProvider.notifier)
          .cancel(widget.appointment.id);
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.appointment.status == AppointmentStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.md,
        vertical: DesignTokens.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.sm),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.event),
              ),
              title: Text(
                widget.doctorName,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${widget.specialty} • ${widget.formattedDate}',
              ),
              trailing: _StatusChip(status: widget.appointment.status),
            ),
            if (isPending)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: DesignTokens.sm,
                    bottom: DesignTokens.xs,
                  ),
                  child: TextButton(
                    onPressed: _isCancelling ? null : _handleCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.error,
                              ),
                            ),
                          )
                        : const Text('Cancel'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case AppointmentStatus.confirmed:
        color = AppColors.success;
        break;
      case AppointmentStatus.cancelled:
        color = AppColors.textSecondary;
        break;
      case AppointmentStatus.pending:
        color = AppColors.warning;
        break;
    }
    return Chip(
      label: Text(
        status == AppointmentStatus.pending
            ? 'Pending'
            : status == AppointmentStatus.confirmed
            ? 'Confirmed'
            : 'Cancelled',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
