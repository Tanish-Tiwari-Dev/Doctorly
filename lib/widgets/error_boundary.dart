import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/error_reporter_provider.dart';
import '../services/logger.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      final stack = details.stack ?? StackTrace.empty;
      _handleError(details.exception, stack);
      FlutterError.presentError(details);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = FlutterError.dumpErrorToConsole;
    super.dispose();
  }

  Future<void> _handleError(Object error, StackTrace stack) async {
    LoggerService.instance.log.severe('Uncaught error', error, stack);
    final reporter = ref.read(errorReporterProvider);
    await reporter.report(error, stack);
    if (mounted) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please restart the app. If the problem persists, contact support.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                   FilledButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
