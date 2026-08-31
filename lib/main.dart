import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/env.dart';
import 'package:doctorly/providers/error_reporter_provider.dart';
import 'package:doctorly/services/error_reporter.dart';
import 'package:doctorly/services/logger.dart';

import 'package:doctorly/utils/app_router.dart';
import 'package:doctorly/widgets/error_boundary.dart';

Future<void> main() async {
  Future<void> bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Render a loading screen IMMEDIATELY to prevent Android from killing the app
    runApp(
      const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );

    // Now do the heavy lifting
    await LoggerService.instance.initialize();

    final container = ProviderContainer();

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
        LoggerService.instance.log.info(
          'Supabase Initialized: ${Env.supabaseUrl}',
        );
      } catch (e, st) {
        LoggerService.instance.log.severe(
          'Supabase initialization failed',
          e,
          st,
        );
        initialized = false;
      }
    }

    final router = buildAppRouter(container);

    if (!initialized) {
      // If init failed, render the error screen instead of the loading screen
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Initialization failed. Check logs for details.'),
            ),
          ),
        ),
      );
      return;
    }

    // If everything succeeded, render the actual app
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: ErrorBoundary(child: MainApp(router: router)),
      ),
    );
  }

  // Run the app inside a guarded zone, with or without Sentry
  if (Env.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
      },
      appRunner: () => runZonedGuarded(() => bootstrap(), (error, stack) async {
        LoggerService.instance.log.severe('Uncaught zone error', error, stack);
        const SentryErrorReporter().report(
          error,
          stack,
          context: {'source': 'runZonedGuarded'},
        );
      }),
    );
  } else {
    runZonedGuarded(() => bootstrap(), (error, stack) {
      LoggerService.instance.log.severe('Uncaught zone error', error, stack);
    });
  }
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A6EBD))
            .copyWith(
              primary: const Color(0xFF0A6EBD),
              surface: const Color(0xFFF5F5F5),
              onSurface: const Color(0xFF0F172A),
              secondary: const Color(0xFF64748B),
            ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F172A),
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F172A),
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A6EBD),
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          labelSmall: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
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
            borderSide: const BorderSide(color: Color(0xFF0A6EBD), width: 2),
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
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
