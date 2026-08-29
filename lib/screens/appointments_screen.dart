import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../providers/appointments_provider.dart';
import '../providers/doctor_provider.dart';
import '../widgets/empty_state.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments', style: GoogleFonts.inter()),
        centerTitle: false,
      ),
      body: appointments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load appointments',
          subtitle: 'Please check your connection and try again.',
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy,
              title: 'No appointments yet.',
              subtitle:
                  "Book your first appointment from a doctor's profile.",
            );
          }
          final df = DateFormat('EEE, MMM d \u2022 h:mm a');
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
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

class _AppointmentCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.event),
        ),
        title: Text(
          doctorName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$specialty \u2022 $formattedDate'),
        trailing: _StatusChip(status: appointment.status),
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
        color = Colors.green;
        break;
      case AppointmentStatus.cancelled:
        color = Colors.grey;
        break;
      case AppointmentStatus.pending:
        color = Colors.orange;
        break;
    }
    return Chip(
      label: Text(
        status == AppointmentStatus.pending
            ? 'Pending'
            : status == AppointmentStatus.confirmed
                ? 'Confirmed'
                : 'Cancelled',
        style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
