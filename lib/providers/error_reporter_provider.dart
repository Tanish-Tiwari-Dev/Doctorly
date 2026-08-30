import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/error_reporter.dart';

final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return const SentryErrorReporter();
});
