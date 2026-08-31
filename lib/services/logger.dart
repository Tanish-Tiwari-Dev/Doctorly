import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerService {
  LoggerService._();

  static final LoggerService instance = LoggerService._();
  Logger? _log;

  Logger get log => _log ??= Logger('Doctorly');

  Future<void> initialize() async {
    if (_log != null) return;

    hierarchicalLoggingEnabled = true;

    _log = Logger('Doctorly');

    if (kReleaseMode) {
      Logger.root.level = Level.INFO;
      _log!.level = Level.INFO;
    } else {
      Logger.root.level = Level.ALL;
      _log!.level = Level.ALL;
    }

    Logger.root.onRecord.listen((record) {
      if (kReleaseMode && record.level < Level.INFO) return;
      final message =
          '${record.level.name}: ${record.loggerName}: ${record.message}';
      if (record.error != null) {
        debugPrint('$message\n${record.error}');
      } else {
        debugPrint(message);
      }
    });
  }
}
