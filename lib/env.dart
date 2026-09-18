/// Exception thrown when mandatory configuration is missing.
class ConfigurationException implements Exception {
  /// Creates a [ConfigurationException] with the given [message].
  const ConfigurationException(this.message);

  /// Description of the configuration failure.
  final String message;

  @override
  String toString() => message;
}

/// Environment configuration provider using `--dart-define`.
class Env {
  /// Supabase project URL passed via `--dart-define=SUPABASE_URL=...`.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase publishable key passed via `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Optional Sentry DSN passed via `--dart-define=SENTRY_DSN=...`.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Whether required Supabase credentials are configured.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  /// Ensures required configuration is present, otherwise throws [ConfigurationException].
  static void requireConfigured() {
    if (!isConfigured) {
      throw const ConfigurationException(
        'Supabase is not configured. Pass SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY via --dart-define.',
      );
    }
  }
}

