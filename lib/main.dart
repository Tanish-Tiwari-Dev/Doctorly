import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env if present; --dart-define values remain available as a fallback
  // for CI / build pipelines that prefer not to ship a .env file.
  try {
    await dotenv.load(fileName: '.env');
    // Only fall back to --dart-define if .env didn't contain the key.
    const urlFromDefine = String.fromEnvironment('SUPABASE_URL');
    const keyFromDefine =
        String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    Env.supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ??
        (urlFromDefine.isNotEmpty ? urlFromDefine : '');
    Env.supabasePublishableKey = dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY') ??
        (keyFromDefine.isNotEmpty ? keyFromDefine : '');
  } catch (e, st) {
    debugPrint('dotenv load failed: $e\n$st');
    // Fall back to --dart-define if .env is missing.
    Env.supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    Env.supabasePublishableKey =
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  }

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
    debugPrint('Supabase Initialized: ${Env.supabaseUrl}');
    try {
      await Supabase.instance.client.auth.signInAnonymously();
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  } else {
    debugPrint(
      'Supabase is not configured. Add SUPABASE_URL and '
      'SUPABASE_PUBLISHABLE_KEY to .env (see .env.example) or pass them '
      'via --dart-define.',
    );
  }

  // Build a single ProviderContainer that owns the auth-driven GoRouter.
  // Using UncontrolledProviderScope means widgets in the tree read from
  // this container (which already has the auth listener wired).
  final container = ProviderContainer();
  final router = buildAppRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MainApp(router: router),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Doctorly',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6EBD),
        ).copyWith(
          primary: const Color(0xFF0A6EBD),
          surface: const Color(0xFFF5F5F5),
          onSurface: const Color(0xFF0F172A),
          secondary: const Color(0xFF64748B),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          bodyLarge: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color(0xFF0F172A),
          ),
          labelLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A6EBD),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          centerTitle: false,
          foregroundColor: const Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF0A6EBD),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: Color(0xFF0A6EBD)),
          unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
          selectedLabelTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A6EBD),
          ),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFF64748B)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFF0A6EBD).withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
