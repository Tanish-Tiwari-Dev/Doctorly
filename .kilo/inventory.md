[DEAD CODE]
lib/widgets/specialty_chip.dart:7 — SpecialtyChipSliverDelegate is defined but never imported or used anywhere (home_screen.dart has its own inline _SpecialtyChipDelegate at line 338)

[DUPLICATION / REPETITION]
lib/providers/doctor_provider.dart:51-96 — sortedDoctorsProvider, filteredDoctorsProvider, and topRatedDoctorsProvider have overlapping sort/filter logic; sortedDoctorsProvider is consumed by filteredDoctorsProvider, creating redundant re-sorts on every read
lib/screens/home_screen.dart:338-395 — _SpecialtyChipDelegate duplicates the dead lib/widgets/specialty_chip.dart functionality
lib/widgets/doctor_card.dart:45-46 — Hero tag 'doctor-avatar-${doctor.id}${compact ? '-compact' : ''}' while lib/screens/doctor_details_screen.dart:82 uses 'doctor-avatar-${doctor.id}'; non-compact cards in grids/lists share tags with the detail screen, risking collisions if the same doctor appears in multiple hero contexts simultaneously
Throughout lib/screens/ and lib/widgets/ — GoogleFonts.inter() and GoogleFonts.plusJakartaSans() called inline instead of Theme text styles (e.g., lib/screens/auth_screen.dart:69, lib/screens/home_screen.dart:162, lib/widgets/doctor_card.dart:63)
Throughout lib/screens/ and lib/widgets/ — hardcoded Color(0xFF...) values scattered across every screen instead of centralized in theme (e.g., lib/screens/home_screen.dart:117, 189, 259; lib/screens/auth_screen.dart:240; lib/screens/booking_screen.dart:298)

[ANTI-PATTERNS / CODE SMELLS]
lib/screens/auth_screen.dart:34 — Supabase.instance.client called directly in a screen widget (violates the rule that all Supabase access must go through supabaseClientProvider)
lib/screens/home_screen.dart:62-67 — widget calls ref.read(supabaseClientProvider).rpc() directly (should go through DoctorRepository)
lib/main.dart:26,38,42,45 — debugPrint statements (should be routed through package:logging via lib/services/logger.dart singleton)
lib/providers/booking_provider.dart:14-18 — date! and time! null assertions on nullable fields after null guard (violates AGENTS.md "never use ! outside tests")
lib/providers/booking_provider.dart:22 — scheduledFor! null assertion after null guard
lib/widgets/doctor_card.dart:50 — NetworkImage used directly without caching (bandwidth cost)
lib/screens/booking_screen.dart:137 — NetworkImage used directly without caching
lib/providers/doctor_provider.dart:65-69 — searchQueryProvider, selectedSpecialtyProvider, nearbyResultsProvider are global providers for transient UI state (provider pollution)

[SECURITY / SECRETS]
pubspec.yaml:28 — .env listed as a Flutter asset; this bundles the .env file into the app binary/web bundle, risking key leakage if .env contains real keys
lib/env.dart:4-6 — SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY consumed via String.fromEnvironment; AGENTS.md explicitly forbids dart-define for secrets in production
supabase/schema.sql:51-52 — "doctors read" policy uses `using (true)` which is permissive, allowing anyone (including anon) to read all doctor data
lib/main.dart:40 — Anonymous auth (signInAnonymously) with no visible rate limiting or abuse caps in the app

[PRODUCTION GAPS]
test/ directory does not exist — zero tests
.github/workflows does not exist — no CI/CD
android/app/src/ — no keystore/signing config present (no key.properties, no release signing config)
No image caching (NetworkImage used directly in doctor_card.dart:50 and booking_screen.dart:137)
No offline support / caching
No analytics / observability
lib/providers/appointments_provider.dart:47-68 — cancel() method exists but appointments_screen.dart never calls it (no cancel button in UI)
No Realtime subscription for favorites sync (favorites only refresh on screen load or manual toggle)
lib/widgets/empty_state.dart:22,29 — uses hardcoded Colors.grey.shade400/700 instead of theme colors
Hero tag collisions in grid views — lib/screens/home_screen.dart:314 uses DoctorCard in a SliverGrid; if the same doctor appears in multiple hero contexts simultaneously, tags collide
No global error boundary / handler for uncaught Flutter errors

[ARCHITECTURE DEBT]
lib/utils/location_service.dart:3-37 vs lib/providers/location_provider.dart:4 — responsibility split is reasonable (service does work, provider exposes it)
lib/widgets/specialty_chip.dart:7 — dead code from Phase 1, never imported (home_screen.dart uses its own inline _SpecialtyChipDelegate at line 338)
lib/screens/nearby_screen.dart — does not exist (already removed, no dead route)
lib/utils/constants.dart — does not exist (already removed when mock data moved to supabase/seed.sql)
lib/providers/booking_provider.dart vs lib/providers/appointments_provider.dart — boundary is clear: booking manages local UI state (date/time), appointments manages server state (CRUD)

---

SUMMARY
- Total findings per bucket: DEAD CODE: 1, DUPLICATION: 5, ANTI-PATTERNS: 8, SECURITY: 4, PRODUCTION GAPS: 11, ARCHITECTURE DEBT: 5 = 34 total
- Top 5 highest-impact items to fix first:
  1. Remove .env from pubspec.yaml assets (line 28) to prevent key leakage in bundled app
  2. Move Supabase.instance.client access out of auth_screen.dart (line 34) into a proper auth provider
  3. Move the RPC call out of home_screen.dart (line 62) into DoctorRepository
  4. Add image caching for NetworkImage usages (doctor_card.dart:50, booking_screen.dart:137)
  5. Replace all debugPrint calls (main.dart:26,38,42,45) with structured logging via lib/services/logger.dart
- Blockers that would prevent a Play Store / production launch:
  1. No Android app signing configuration (no keystore/signing config in android/)
  2. .env bundled as asset risks exposing Supabase anon key in production builds
  3. Zero automated tests and no CI/CD pipeline
  4. Anonymous auth without rate limiting creates abuse surface
  5. No error boundary for uncaught Flutter errors could cause silent crashes