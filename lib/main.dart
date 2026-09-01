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
        scaffoldBackgroundColor: DesignTokens.scaffoldBackground,
        primaryColor: DesignTokens.primary,
        cardColor: DesignTokens.cardBackground,
        dividerColor: DesignTokens.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primary,
        ).copyWith(
          primary: DesignTokens.primary,
          surface: DesignTokens.scaffoldBackground,
          onSurface: DesignTokens.textPrimary,
          secondary: DesignTokens.textSecondary,
          error: DesignTokens.error,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: DesignTokens.textPrimary,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textPrimary,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF475569),
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF475569),
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: DesignTokens.textSecondary,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          color: DesignTokens.cardBackground,
          shadowColor: Color(0x0F1E293B),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: DesignTokens.scaffoldBackground,
          elevation: 0,
          centerTitle: false,
          foregroundColor: DesignTokens.textPrimary,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textPrimary,
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
              color: DesignTokens.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.md,
            vertical: 14,
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(color: DesignTokens.primary),
          unselectedIconTheme: IconThemeData(
            color: DesignTokens.textSecondary,
          ),
          selectedLabelTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.primary,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: DesignTokens.textSecondary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: DesignTokens.primaryLight,
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
