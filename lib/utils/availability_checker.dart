/// Utility for calculating doctor availability status based on operating hours.
library;

/// Determines whether a doctor is currently open based on [openingTime] and [closingTime].
///
/// Accepts time strings in HH:mm or HH:mm:ss format (e.g., "09:00", "17:30:00").
/// An optional [currentTime] parameter can be supplied for testing purposes.
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
    // Standard daytime shift (e.g., 09:00 - 17:00)
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  } else {
    // Overnight shift (e.g., 22:00 - 06:00)
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }
}

int _parseTimeToMinutes(String timeStr, {required int defaultMinutes}) {
  try {
    final parts = timeStr.trim().split(':');
    if (parts.length >= 2) {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour * 60 + minute;
    }
  } catch (_) {
    // Fall back to default if format parsing fails
  }
  return defaultMinutes;
}
