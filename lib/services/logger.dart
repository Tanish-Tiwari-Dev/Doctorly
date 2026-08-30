import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerService {
  LoggerService._();

  static final LoggerService instance = LoggerService._();
  late final Logger log;

  Future<void> initialize() async {
    hierarchicalLoggingEnabled = true;

    log = Logger('Doctorly');

    if (kReleaseMode) {
      Logger.root.level = Level.INFO;
      log.level = Level.INFO;
    } else {
      Logger.root.level = Level.ALL;
      log.level = Level.ALL;
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
