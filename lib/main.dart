import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';
import 'providers/error_reporter_provider.dart';
import 'services/logger.dart';
import 'utils/app_router.dart';
import 'widgets/error_boundary.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await LoggerService.instance.initialize();

    try {
      await dotenv.load(fileName: '.env');
    } catch (e, st) {
      LoggerService.instance.log.warning('dotenv load failed', e, st);
    }

    final urlFromDefine = const String.fromEnvironment('SUPABASE_URL');
    final keyFromDefine = const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    String? maybeUrl;
    String? maybeKey;
    try {
      maybeUrl = dotenv.maybeGet('SUPABASE_URL');
      maybeKey = dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY');
    } catch (e, st) {
      LoggerService.instance.log.warning('dotenv maybeGet failed', e, st);
    }
    Env.supabaseUrl = maybeUrl ??
        (urlFromDefine.isNotEmpty ? urlFromDefine : '');
    Env.supabasePublishableKey = maybeKey ??
        (keyFromDefine.isNotEmpty ? keyFromDefine : '');

    // Anonymous auth is currently used as a placeholder until real auth
    // (email/OTP + Google + Apple) is implemented in Phase 8.
    // Risk: anon auth can be abused for credential stuffing, spam, and
    // rate-limit evasion because no identity barrier exists.
    // Mitigation today: Supabase project-level rate limits + RLS.
    // TODO(#8): Migrate to real auth providers and remove anonymous sign-in.
    bool initialized = true;
    try {
      Env.requireConfigured();
    } on ConfigurationException catch (e) {
      LoggerService.instance.log.severe('Configuration error', e);
      initialized = false;
    }

    if (initialized) {
      try {
        await Supabase.initialize(
          url: Env.supabaseUrl,
          publishableKey: Env.supabasePublishableKey,
        );
        LoggerService.instance.log.info('Supabase Initialized: ${Env.supabaseUrl}');
      } catch (e, st) {
        LoggerService.instance.log.severe('Supabase initialization failed', e, st);
        initialized = false;
      }
    }

    if (initialized) {
      try {
        await Supabase.instance.client.auth.signInAnonymously()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        LoggerService.instance.log.severe('Anonymous sign-in failed', e);
      }
    }

    final container = ProviderContainer();
    final router = buildAppRouter(container);

    FlutterError.onError = (details) {
      LoggerService.instance.log.severe(
        'Flutter framework error',
        details.exception,
        details.stack ?? StackTrace.empty,
      );
      final reporter = container.read(errorReporterProvider);
      unawaited(
        reporter.report(
          details.exception,
          details.stack ?? StackTrace.empty,
          context: {'library': details.library},
        ),
      );
      FlutterError.dumpErrorToConsole(details);
    };

    if (!initialized) {
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Initialization failed. Check logs for details.'),
            ),
          ),
        ),
      );
      return;
    }

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: ErrorBoundary(
          child: MainApp(router: router),
        ),
      ),
    );
  }, (error, stack) async {
    LoggerService.instance.log.severe('Uncaught zone error', error, stack);
  });
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
