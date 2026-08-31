import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/services/error_reporter.dart';

final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return const SentryErrorReporter();
});
