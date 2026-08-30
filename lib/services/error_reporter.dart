abstract class ErrorReporter {
  Future<void> report(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  });
}

class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  Future<void> report(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  }) async {}
}
