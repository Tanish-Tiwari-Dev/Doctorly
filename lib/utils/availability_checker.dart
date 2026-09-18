import 'package:doctorly/utils/doctor_strings.dart';

/// Availability status enum for doctor OPD.
enum DoctorOpdStatus {
  openNow,
  opensAt,
  closedToday,
  byAppointmentOnly,
  callToConfirm,
}

/// Rich availability calculation model consuming OPD days, timings, and appointment flags.
class DoctorAvailabilityInfo {
  const DoctorAvailabilityInfo({
    required this.status,
    required this.label,
    this.nextOpenTime,
  });

  final DoctorOpdStatus status;
  final String label;
  final String? nextOpenTime;

  bool get isOpen => status == DoctorOpdStatus.openNow;
}

/// Determines whether a doctor is currently open based on [openingTime] and [closingTime].
/// Preserved for backward compatibility with existing tests and filters.
bool isDoctorOpen(
  String? openingTime,
  String? closingTime, [
  DateTime? currentTime,
]) {
  if (openingTime == null || closingTime == null) {
    return true; // Default to open if hours are unspecified
  }

  final now = currentTime ?? DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;

  final startMinutes = _parseTimeToMinutes(openingTime, defaultMinutes: 9 * 60);
  final endMinutes = _parseTimeToMinutes(closingTime, defaultMinutes: 17 * 60);

  if (startMinutes == endMinutes) {
    return true; // 24-hour service
  }

  if (startMinutes < endMinutes) {
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  } else {
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }
}

/// Comprehensive availability calculator for Disha V1 OPD schedules.
///
/// Evaluates [opdDays], [opdOpen], [opdClose], and [opdByAppointment].
/// Returns one of:
/// - "Open now"
/// - "Opens at X"
/// - "Closed today"
/// - "By appointment only"
/// - "Call to confirm OPD timing" (when hours/days are unknown/empty)
DoctorAvailabilityInfo calculateDoctorAvailability({
  required List<String> opdDays,
  String? opdOpen,
  String? opdClose,
  bool opdByAppointment = false,
  DateTime? currentTime,
}) {
  if (opdByAppointment) {
    return const DoctorAvailabilityInfo(
      status: DoctorOpdStatus.byAppointmentOnly,
      label: DoctorStrings.byAppointmentOnly,
    );
  }

  final now = currentTime ?? DateTime.now();
  final todayDayName = _getDayName(now.weekday);

  // If no OPD days or no hours specified, return "Call to confirm OPD timing"
  if (opdDays.isEmpty || opdOpen == null || opdClose == null) {
    return const DoctorAvailabilityInfo(
      status: DoctorOpdStatus.callToConfirm,
      label: DoctorStrings.callToConfirmOpd,
    );
  }

  // Check if doctor operates today
  final isOpenToday = opdDays.any((d) => _matchesDayName(d, todayDayName));
  if (!isOpenToday) {
    return const DoctorAvailabilityInfo(
      status: DoctorOpdStatus.closedToday,
      label: DoctorStrings.closedToday,
    );
  }

  final currentMinutes = now.hour * 60 + now.minute;
  final startMinutes = _parseTimeToMinutes(opdOpen, defaultMinutes: 9 * 60);
  final endMinutes = _parseTimeToMinutes(opdClose, defaultMinutes: 17 * 60);

  if (startMinutes == endMinutes) {
    return const DoctorAvailabilityInfo(
      status: DoctorOpdStatus.openNow,
      label: DoctorStrings.openNow,
    );
  }

  if (startMinutes < endMinutes) {
    if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
      return const DoctorAvailabilityInfo(
        status: DoctorOpdStatus.openNow,
        label: DoctorStrings.openNow,
      );
    } else if (currentMinutes < startMinutes) {
      return DoctorAvailabilityInfo(
        status: DoctorOpdStatus.opensAt,
        label: DoctorStrings.opensAt(opdOpen),
        nextOpenTime: opdOpen,
      );
    } else {
      return const DoctorAvailabilityInfo(
        status: DoctorOpdStatus.closedToday,
        label: DoctorStrings.closedToday,
      );
    }
  } else {
    // Overnight schedule
    final isOpen = currentMinutes >= startMinutes || currentMinutes < endMinutes;
    if (isOpen) {
      return const DoctorAvailabilityInfo(
        status: DoctorOpdStatus.openNow,
        label: DoctorStrings.openNow,
      );
    } else {
      return DoctorAvailabilityInfo(
        status: DoctorOpdStatus.opensAt,
        label: DoctorStrings.opensAt(opdOpen),
        nextOpenTime: opdOpen,
      );
    }
  }
}

String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Monday';
  }
}

bool _matchesDayName(String candidate, String targetDay) {
  final c = candidate.trim().toLowerCase();
  final t = targetDay.trim().toLowerCase();
  if (c == t) return true;
  if (t.startsWith(c) || c.startsWith(t.substring(0, 3))) return true;
  return false;
}

int _parseTimeToMinutes(String timeStr, {required int defaultMinutes}) {
  try {
    final parts = timeStr.trim().split(':');
    if (parts.length >= 2) {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour * 60 + minute;
    }
  } catch (_) {}
  return defaultMinutes;
}
