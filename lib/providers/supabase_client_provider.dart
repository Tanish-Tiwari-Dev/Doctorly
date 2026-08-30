import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!Env.isConfigured) {
    throw const ConfigurationException(
      'Supabase is not configured. Add SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY to a .env file (see .env.example) or pass '
      'them via --dart-define.',
    );
  }
  return Supabase.instance.client;
});
