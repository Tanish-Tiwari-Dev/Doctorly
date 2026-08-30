class ConfigurationException implements Exception {
  const ConfigurationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Env {
  // Populated by main() at startup from .env (preferred) or from
  // --dart-define overrides (used by CI / build pipelines).
  static String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  static String supabasePublishableKey =
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static void requireConfigured() {
    if (!isConfigured) {
      throw const ConfigurationException(
        'Supabase is not configured. Add SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY to a .env file (see .env.example) or pass '
        'them via --dart-define.',
      );
    }
  }
}
