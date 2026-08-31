import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, cancelled }

@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.doctorId,
    required this.scheduledFor,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String doctorId;
  final DateTime scheduledFor;
  final AppointmentStatus status;
  final DateTime createdAt;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      scheduledFor: DateTime.parse(json['scheduled_for'] as String),
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static AppointmentStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
