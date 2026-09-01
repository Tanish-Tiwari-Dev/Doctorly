import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:doctorly/env.dart';
import 'package:doctorly/providers/error_reporter_provider.dart';
import 'package:doctorly/services/cache_service.dart';
import 'package:doctorly/services/error_reporter.dart';
import 'package:doctorly/services/logger.dart';
import 'package:doctorly/services/notification_service.dart';

import 'package:doctorly/utils/app_router.dart';
import 'package:doctorly/utils/design_tokens.dart';
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
    await NotificationService.instance.initialize();
    await CacheService.instance.initialize();

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
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        primaryColor: const Color(0xFF0A7E8C),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE5E7EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7E8C))
            .copyWith(
              primary: const Color(0xFF0A7E8C),
              surface: const Color(0xFFF7F9FC),
              onSurface: const Color(0xFF111827),
              secondary: const Color(0xFF6B7280),
            ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF374151),
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF4B5563),
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF6B7280),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          color: Colors.white,
          shadowColor: Color(0x0A1A2B33),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF7F9FC),
          elevation: 0,
          centerTitle: false,
          foregroundColor: const Color(0xFF111827),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
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
            borderSide: const BorderSide(color: Color(0xFF0A7E8C), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.md,
            vertical: 14,
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: Color(0xFF0A7E8C)),
          unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
          selectedLabelTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A7E8C),
          ),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFF64748B)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFF0A7E8C).withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
