import 'package:sentry_flutter/sentry_flutter.dart';

/// Abstract interface for crash and error reporting.
abstract class ErrorReporter {
  /// Reports an exception or error [error] with optional [stack] trace and metadata [context].
  Future<void> report(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  });
}

/// Sentry implementation of [ErrorReporter].
class SentryErrorReporter implements ErrorReporter {
  /// Creates a [SentryErrorReporter].
  const SentryErrorReporter();

  @override
  Future<void> report(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  }) async {
    if (context != null && context.isNotEmpty) {
      Sentry.configureScope((scope) {
        context.forEach((key, value) {
          scope.setContexts(key, value);
        });
      });
    }
    await Sentry.captureException(error, stackTrace: stack);
  }
}
