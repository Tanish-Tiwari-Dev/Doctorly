class ConfigurationException implements Exception {
  const ConfigurationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static void requireConfigured() {
    if (!isConfigured) {
      throw const ConfigurationException(
        'Supabase is not configured. Pass SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY via --dart-define.',
      );
    }
  }
}
