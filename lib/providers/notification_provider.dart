import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/services/notification_service.dart';

/// Provider exposing the [NotificationService] singleton.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
