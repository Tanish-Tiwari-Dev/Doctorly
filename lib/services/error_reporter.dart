import 'package:sentry_flutter/sentry_flutter.dart';

abstract class ErrorReporter {
  Future<void> report(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  });
}

class SentryErrorReporter implements ErrorReporter {
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
