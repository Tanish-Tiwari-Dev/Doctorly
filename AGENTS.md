Stack
Flutter ^3.x (Android + Web targets)
State: flutter_riverpod ^2.6.1 (AsyncNotifier pattern, no codegen)
Routing: go_router ^14.3.0 (StatefulShellRoute.indexedStack)
Backend: supabase_flutter ^2.5.0 (PostgreSQL + PostGIS, anon auth today)
Location: geolocator ^13.0.2
Fonts: google_fonts ^7.0.1 (Inter)

Features
- Network Connectivity Monitoring
- Secure Storage
- Hive Offline Cache
- Local Notifications
- In-App Reporting
- Reviews System
- Advanced Filters
- Premium UI Design System

Hard conventions
No dart-define for secrets in production; use --dart-define only for non-secret config (env name), never for keys.
All async state lives in AsyncNotifier / AsyncNotifierProvider; never call Supabase from widgets directly.
All Supabase access goes through supabaseClientProvider; never Supabase.instance.client directly in screens/widgets.
Provider naming: fooProvider (sync), fooListProvider (async list), fooNotifierProvider not allowed — use fooProvider.notifier.
Files: snake_case; one screen per file under lib/screens/; reusable widgets under lib/widgets/; providers under lib/providers/; services under lib/services/.
No print() anywhere; route everything through package:logging via a lib/services/logger.dart singleton.
Every public function gets a doc comment (///).
Null safety: never use ! outside tests; prefer ?? and early returns.
Tests live next to source as *.test.dart (unit) and in test/widget/ (widget).

Architecture rules
Repository layer is REQUIRED between Notifiers and Supabase (Phase 6 goal).
Notifiers must not know SQL column names; repositories map rows ↔ models.
Models are immutable; mutation via copyWith.
Routing: shell routes for tabs, top-level routes for detail/booking.
Errors: surface via AsyncValue.error; never swallow silently.
All providers fetching remote data MUST use `.autoDispose`.
All API calls MUST be wrapped in try-catch and mapped to `RepositoryException`.
NO hardcoded colors, paddings, or radii are allowed in UI files. Everything MUST use `DesignTokens` or `Theme.of(context)`.

Forbidden
Hot restart as a fix — always root-cause.
// TODO without an issue link.
Hardcoded user_id (legacy MVP artifact — must be replaced by real auth in Phase 8).
Direct Supabase.instance.client calls outside lib/services/.
Inline GoogleFonts.inter(...) styles — use the theme's TextTheme.
