# Doctorly — Comprehensive Project Context & Technical Knowledge Base

**Last Updated:** 2026-09-18  
**Document Status:** Complete Architecture & Project Context  
**Primary Target:** Android (`minSdk` 21 / Flutter default, `compileSdk` 36, `targetSdk` Flutter default) + Web  

---

## 🗺️ Quick Map

Annotated directory overview of the Doctorly codebase:

```text
doctorly/
├── AGENTS.md                                # Team & AI rules, architecture invariants, forbidden patterns
├── analysis_options.yaml                    # Dart analysis configuration (package:flutter_lints/flutter.yaml)
├── android/                                 # Native Android host project
│   ├── app/
│   │   ├── build.gradle.kts                 # Application ID (com.disha.directory), desugaring, signing
│   │   └── src/main/AndroidManifest.xml     # <queries> (tel, geo, https for Android 11+ visibility), permissions
│   ├── build.gradle.kts                     # Root buildscript, Kotlin 2.0 compiler options, Google services plugin
│   └── settings.gradle.kts                  # Flutter Gradle plugin loader, AGP 8.11.1, Kotlin 2.2.20
├── docs/                                    # Architectural reference docs
│   ├── data/                                # TSV datasets & test fixtures (doctorly_test_data.tsv)
│   ├── PROJECT_CONTEXT.md                   # [THIS FILE] Complete shared technical knowledge base
│   └── PROJECT_MAP.md                       # High-level architecture map
├── lib/                                     # Dart / Flutter core source
│   ├── config/                              # Runtime feature toggles
│   │   └── app_features.dart                # Feature flags (e.g. showBooking for V1 directory vs V2)
│   ├── env.dart                             # Safe compile-time environment flags via --dart-define
│   ├── main.dart                            # Zone error boundary, bootstrap, theme setup, Sentry initialization
│   ├── features/                            # Feature-first modular code
│   │   ├── appointments/                    # Appointments booking and management (V2 hidden behind showBooking)
│   │   │   ├── data/repositories/           # AppointmentsRepository, AvailabilityRepository
│   │   │   ├── domain/models/               # Appointment model
│   │   │   └── presentation/                # AppointmentsScreen, BookingScreen, AppointmentsNotifier, etc.
│   │   ├── auth/                            # Authentication (Magic Link OTP, Google OAuth, Anonymous guest mode)
│   │   │   ├── data/repositories/           # AuthRepository (RPC merge, delete account, profile setup)
│   │   │   └── presentation/                # AuthScreen, SettingsScreen, AuthNotifier, AuthState
│   │   ├── doctor/                          # Doctor catalog, reviews, reporting, nearby PostGIS search
│   │   │   ├── data/repositories/           # DoctorsRepository, ReviewsRepository, ReportsRepository
│   │   │   ├── domain/models/               # Doctor, Specialty, DoctorReview models
│   │   │   └── presentation/                # HomeScreen, DoctorDetailsScreen, filters, sheets, notifiers
│   │   ├── favorites/                       # User favorited doctors
│   │   │   ├── data/repositories/           # FavoritesRepository
│   │   │   └── presentation/                # FavoritesScreen, FavoritesNotifier, skeletons
│   │   └── onboarding/                      # Initial walkthrough experience
│   │       ├── data/repositories/           # OnboardingRepository (SharedPreferences backing)
│   │       └── presentation/                # OnboardingScreen, OnboardingNotifier
│   ├── providers/                           # Core cross-feature Riverpod providers
│   │   ├── connectivity_provider.dart       # StreamProvider tracking network connectivity (connectivity_plus)
│   │   ├── error_reporter_provider.dart     # Sentry & fallback logger provider
│   │   └── supabase_client_provider.dart    # Centralized SupabaseClient provider
│   ├── services/                            # Reusable infrastructure singletons
│   │   ├── cache_service.dart               # Hive offline cache for doctors
│   │   ├── error_reporter.dart              # Sentry / Logger reporter abstractions
│   │   ├── location_service.dart            # Geolocator wrapper with permission handling
│   │   ├── logger.dart                      # Package:logging root singleton
│   │   ├── notification_service.dart        # flutter_local_notifications appointment reminders
│   │   └── secure_storage_service.dart      # flutter_secure_storage encrypted key-value store
│   ├── utils/                               # Cross-cutting utilities and design system
│   │   ├── app_router.dart                  # GoRouter configuration with StatefulShellRoute.indexedStack
│   │   ├── availability_checker.dart        # 5-state OPD calculation (open now, opens at, closed, by appt, confirm)
│   │   ├── design_tokens.dart               # Theme colors, paddings, border radii, shadows
│   │   ├── disha_categories.dart            # 8 Disha patient-facing categories & service slug mapping
│   │   ├── doctor_strings.dart              # Patient-facing copy, tri-state formatters, disclaimers
│   │   ├── error_localizer.dart             # Humanized repository exception translation
│   │   └── repository_exception.dart        # Standardized typed error hierarchy
│   └── widgets/                             # Global reusable UI components
│       ├── bottom_nav_scaffold.dart         # Responsive shell scaffold (bottom bar / nav rail)
│       ├── empty_state.dart                 # Polished empty list placeholders
│       ├── error_boundary.dart              # Custom Flutter error widget fallback
│       ├── max_width_container.dart         # Adaptive web/tablet layout width clamp
│       └── offline_banner.dart              # Animated no-connection alert banner
├── pubspec.yaml                             # Project dependencies, Flutter SDK ^3.13.1, version 0.1.0+1
├── supabase/                                # Supabase database schema, migrations & RLS policies
│   ├── migrations/                          # Versioned PostgreSQL + PostGIS SQL migrations
│   │   └── 20260918080000_disha_directory_expansion.sql # Disha V1 directory expansion & strict RLS
│   └── SECURITY.md                          # RLS and security documentation
├── tooling/                                 # Dedicated command-line tools
│   └── doctor_import/                       # Standalone TSV import & upsert CLI tool
│       ├── bin/import_doctors.dart          # CLI entry point for external TSV pipeline
│       └── lib/doctor_parser.dart           # Independent parser & phone normalizer (E.164)
└── test/                                    # Unit and Widget tests
    ├── unit/                                # Unit tests (Auth, Filters, Availability, Disha categories, Storage)
    └── widget/                              # Widget tests (Screens, sheets, cards, badges, Disha details)
```

---

## 1. Project Overview

- **App Name:** `doctorly` (Disha V1 Directory)
- **Application ID:** `com.disha.directory` (with debug suffix `.debug` in [android/app/build.gradle.kts](file:///home/me/1.%20Tanish/Doctorly/doctorly/android/app/build.gradle.kts))
- **Version:** `0.1.0+1`
- **Flutter SDK Constraint:** `^3.13.1` (running Dart SDK `^3.13.1`)
- **Android Target / Min SDK:**
  - `compileSdk = 36`
  - `minSdk = flutter.minSdkVersion` (Android 21 / 5.0 Lollipop)
  - `targetSdk = flutter.targetSdkVersion`
  - `Java compatibility`: Java 17 with `coreLibraryDesugaringEnabled = true` (`com.android.tools:desugar_jdk_libs:2.1.4`)
  - **Android 11+ Package Visibility:** Declared in `<queries>` block in `AndroidManifest.xml` for `tel`, `geo`, and `https` schemes to guarantee `url_launcher` operates reliably.
- **Primary Purpose:** Disha healthcare discovery directory for verified medical practitioners and specialists. Users can discover nearby doctors using spatial PostGIS queries, inspect 7-day OPD availability, verify medical credentials (council and registration), call or chat via WhatsApp, get directions, and filter by verified statuses.
- **Main Screens and User Flows:**
  1. **Onboarding Flow:** [OnboardingScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/onboarding/presentation/screens/onboarding_screen.dart) displays introductory slides. Bypassed once `hasSeenOnboarding` is saved to `SharedPreferences`.
  2. **Authentication Flow:** [AuthScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/auth/presentation/screens/auth_screen.dart) allows Magic Link Email OTP login, Google OAuth sign-in, and Anonymous Guest mode. Guest users can convert later to authenticated accounts with automatic RPC data merging.
  3. **Main Indexed Bottom Navigation Shell:** [BottomNavScaffold](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/widgets/bottom_nav_scaffold.dart) provides navigation tabs:
     - **Home:** [HomeScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/doctor/presentation/screens/home_screen.dart) with top-rated carousel, specialty chips, search bar, Near Me GPS button, filter bottom sheet, and doctor cards with open/closed indicators.
     - **Favorites:** [FavoritesScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/favorites/presentation/screens/favorites_screen.dart) displaying user-saved doctors with optimistic toggle updates.
     - **Appointments:** [AppointmentsScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/appointments/presentation/screens/appointments_screen.dart) (V1 hides this tab and route when `AppFeatures.showBooking` is false).
  4. **Doctor Details & Directory Actions:** [DoctorDetailsScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/doctor/presentation/screens/doctor_details_screen.dart) displays verified badge, 24x7 emergency banner, facts row, 7-day OPD schedule, expertise chips, languages, directions, collapsible "How we verify" card, statutory medical disclaimer footer (call 108 / nearest hospital), and sticky bottom action bar (Call / WhatsApp / Directions) with disabled feedback states.
  5. **Verification Transparency:** [VerifiedExplainerSheet](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/doctor/presentation/widgets/verified_explainer_sheet.dart) bottom sheet explains verified vs pending verification council statuses.
  6. **Settings Flow:** [SettingsScreen](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/auth/presentation/screens/settings_screen.dart) displays account metadata, sign out, and full account deletion with confirmation.

---

## 2. Tech Stack

- **Languages:** Dart (Flutter application), Kotlin (`2.2.20` on Android host), SQL (PostgreSQL 15+ with PostGIS extensions).
- **UI Framework:** Flutter declarative Material 3 widget tree. No raw Android XML views or Jetpack Compose in the UI layer. Adaptive layout handling with `LayoutBuilder` (wide screen navigation rail vs bottom nav).
- **Architecture Pattern:** Clean Architecture + Feature-First structure:
  - **Domain:** Immutable models (`@immutable`, JSON serialization, `copyWith`).
  - **Data:** Repositories handling database calls, error wrapping into `RepositoryException`, and Hive cache fallback.
  - **Presentation:** Riverpod `AsyncNotifier` / `Notifier` controllers driving UI widgets.
- **Dependency Injection & State Management:** `flutter_riverpod: ^2.6.1`.
  - Manual DI via Riverpod providers (`ref.read`, `ref.watch`).
  - No code-generation (`build_runner` or `@riverpod` annotations are NOT used; pure Riverpod classes).
- **Asynchronous Patterns:** Dart `async/await`, `Future`, `Stream` (for connectivity changes and Supabase auth state subscriptions).
- **Networking & Backend:**
  - Supabase client: `supabase_flutter: ^2.5.0` (talking to PostgreSQL, Auth, PostGIS RPCs, Storage).
  - Base URL and Anon Key passed strictly via compile-time `--dart-define` in [lib/env.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/env.dart).
  - Image networking: `cached_network_image: ^3.4.1` for doctor avatars.
- **Local Storage & Offline Caching:**
  - **Hive:** `hive: ^2.2.3` & `hive_flutter: ^1.1.0` in [lib/services/cache_service.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/cache_service.dart) for offline doctor directory caching.
  - **Encrypted Storage:** `flutter_secure_storage: ^9.0.0` in [lib/services/secure_storage_service.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/secure_storage_service.dart) for sensitive key-value data.
  - **Preferences:** `shared_preferences: ^2.2.2` for onboarding status and anonymous user ID persistence.
- **Navigation:** `go_router: ^14.3.0` with `StatefulShellRoute.indexedStack` for persistent bottom navigation tab state and deep linking support.

---

## 3. Module & Package Structure

Doctorly is structured as a single-module Flutter project with a **Feature-First (Package-by-Feature)** architecture under `lib/features/`, supplemented by shared layers:

```text
lib/
├── features/                  # FEATURE SLICES (Independent business domains)
│   ├── appointments/          # domain/models, data/repositories, presentation (providers, screens, widgets)
│   ├── auth/                  # data/repositories, presentation (providers, screens)
│   ├── doctor/                # domain/models, data/repositories, presentation (providers, screens, widgets)
│   ├── favorites/             # data/repositories, presentation (providers, screens, widgets)
│   └── onboarding/            # data/repositories, presentation (providers, screens)
├── providers/                 # Cross-feature core Riverpod providers (Supabase, Connectivity, ErrorReporter)
├── services/                  # Infrastructure singletons (Logger, Cache, Notification, SecureStorage, Location)
├── utils/                     # Shared cross-cutting utilities (AppRouter, DesignTokens, ErrorLocalizer, Exceptions)
└── widgets/                   # Global reusable presentation widgets (ErrorBoundary, OfflineBanner, EmptyState, etc.)
```

### Layer Responsibilities & Boundaries:
- **Presentation:** Widgets observe Riverpod notifiers (`ref.watch`) and dispatch user actions (`ref.read(...notifier).method()`). Widgets NEVER call Supabase directly.
- **State Management (Providers):** `AsyncNotifier` classes maintain UI state (`AsyncValue<T>`), catch exceptions, map them using `localizeError()`, and interact solely with Repositories.
- **Data (Repositories):** Interface between Supabase / local caches and the application. All Supabase queries, RPC calls, and errors are caught and converted into `RepositoryException`.
- **Domain (Models):** Pure Dart immutable classes without framework dependencies.

---

## 4. Feature Inventory

| Feature / Screen | Entry Route | Controller / Notifier | Data Repositories & Services | Backing Tables / Services |
|---|---|---|---|---|
| **Onboarding** | `/onboarding` | `onboardingProvider` (`OnboardingNotifier`) | `OnboardingRepository` | `SharedPreferences` |
| **Authentication** | `/login` | `authProvider` (`AuthNotifier`) | `AuthRepository` | Supabase Auth, `GoogleSignIn`, `SecureStorageService`, `merge_anonymous_data` RPC |
| **Settings & Profile** | `/settings` | `authProvider` (`AuthNotifier`) | `AuthRepository` | Supabase Auth (`delete_user_account` RPC) |
| **Home / Doctor Discovery** | `/` | `doctorListProvider`, `doctorFilterProvider`, `searchQueryProvider`, `nearbyResultsProvider` | `DoctorsRepository`, `LocationService` | `public.doctors` table, `nearby_doctors` PostGIS RPC, Hive `doctors_cache` |
| **Doctor Details** | `/doctor/:id` | `doctorByIdProvider(id)`, `doctorReviewsProvider(id)` | `DoctorsRepository`, `ReviewsRepository` | `public.doctors`, `public.doctor_reviews` |
| **Review Submission** | Modal Sheet | Local state + `ReviewsRepository` | `ReviewsRepository` | `public.doctor_reviews` |
| **Doctor Reporting** | Modal Sheet | Local state + `ReportsRepository` | `ReportsRepository` | `public.doctor_reports` |
| **Favorites** | `/favorites` | `favoritesProvider` (`FavoritesNotifier`) | `FavoritesRepository` | `public.favorites` junction table |
| **Appointments List** | `/appointments` | `appointmentsProvider` (`AppointmentsNotifier`) | `AppointmentsRepository`, `NotificationService` | `public.appointments` |
| **Appointment Booking** | `/booking/:doctorId` | Local state + `appointmentsProvider` | `AppointmentsRepository`, `AvailabilityRepository`, `NotificationService` | `public.appointments`, `public.availability_slots` |

---

## 5. End-to-End Data Flow Trace

### Example: Booking a Doctor Appointment
```text
1. UI Interaction:
   User selects date and slot on BookingScreen (lib/features/appointments/presentation/screens/booking_screen.dart)
   and taps "Confirm Booking".

2. ViewModel / Notifier Invocation:
   UI calls: ref.read(appointmentsProvider.notifier).create(doctorId, scheduledFor);

3. Notifier Execution:
   lib/features/appointments/presentation/providers/appointments_provider.dart:
   - Reads current authenticated user ID from ref.read(currentUserIdProvider).
   - Calls repo.create(userId, doctorId, scheduledFor).

4. Repository Layer:
   lib/features/appointments/data/repositories/appointments_repository.dart:
   - Executes Supabase insert query:
     _client.from('appointments').insert({
       'user_id': userId,
       'doctor_id': doctorId,
       'scheduled_for': scheduledFor.toUtc().toIso8601String(),
       'status': 'pending',
     }).select().single();
   - Catches any PostgrestException and wraps it into RepositoryException.
   - Maps raw JSON Map into immutable Appointment domain model.

5. Cross-Cutting Service Call:
   Notifier receives the created Appointment, calculates reminder timestamp, and schedules a local notification:
   notificationService.scheduleAppointmentReminder(
     id: notificationId,
     title: 'Upcoming Appointment Reminder',
     body: 'You have an appointment scheduled in 1 hour.',
     scheduledTime: appointment.scheduledFor,
   );

6. State Update & UI Reactivity:
   - Notifier calls ref.invalidateSelf() to trigger an automatic re-fetch of user appointments.
   - GoRouter navigates back or to /appointments.
   - AppointmentsScreen automatically updates via ref.watch(appointmentsProvider).
```

---

## 6. Build System & Tooling

- **Gradle Configuration:**
  - Root: [android/build.gradle.kts](file:///home/me/1.%20Tanish/Doctorly/doctorly/android/build.gradle.kts)
    - Google Services plugin version `4.4.2` (applied conditionally if `google-services.json` is present).
    - Kotlin compilation configured for `KOTLIN_2_0` language and API compatibility.
  - App: [android/app/build.gradle.kts](file:///home/me/1.%20Tanish/Doctorly/doctorly/android/app/build.gradle.kts)
    - Android Gradle Plugin `8.11.1`.
    - `compileSdk = 36`, `JavaVersion.VERSION_17`.
    - `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` enabled.
    - Debug signing configuration used for release builds pending production keystore configuration.
- **Environment Configuration:**
  - Passed via `--dart-define`:
    - `SUPABASE_URL` (mandatory)
    - `SUPABASE_PUBLISHABLE_KEY` (mandatory)
    - `SENTRY_DSN` (optional, activates Sentry crash reporting)
  - Validated at bootstrap by `Env.requireConfigured()` in [lib/env.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/env.dart).
- **Linter & Code Style:**
  - [analysis_options.yaml](file:///home/me/1.%20Tanish/Doctorly/doctorly/analysis_options.yaml) using `package:flutter_lints/flutter.yaml`.
  - Analyzed cleanly with `flutter analyze` (0 warnings, 0 errors).

---

## 7. Cross-Cutting Concerns

- **Logging:**
  - Centralized singleton in [lib/services/logger.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/logger.dart) built upon `package:logging`.
  - `print()` is strictly forbidden in production code.
  - Release mode logs INFO+; debug mode logs ALL.
- **Crash Reporting & Diagnostics:**
  - Sentry integration via `sentry_flutter: ^8.9.0`.
  - Global error trapping in [lib/main.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/main.dart):
    - `FlutterError.onError` sends UI render errors to `ErrorReporter` and `LoggerService`.
    - `runZonedGuarded` captures uncaught asynchronous zone exceptions.
- **Network Connectivity:**
  - Monitored live via `connectivity_plus: ^7.3.1` in [lib/providers/connectivity_provider.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/providers/connectivity_provider.dart).
  - [OfflineBanner](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/widgets/offline_banner.dart) displays an alert banner across screens when offline.
- **Local Notifications:**
  - Handled by [lib/services/notification_service.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/notification_service.dart) using `flutter_local_notifications: ^17.2.4` and `timezone: ^0.9.4`.
  - Automatically requests permission on Android/iOS and schedules exact reminders 1 hour before appointments.
- **Design System & Theming:**
  - Centralized in [lib/utils/design_tokens.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/utils/design_tokens.dart) (colors, spacing `xs` to `xl`, border radii, shadows).
  - Rule: Never use raw hex colors or inline padding numbers in UI files; rely on `DesignTokens` or `Theme.of(context)`.
- **Permissions:**
  - Location permissions handled cleanly by [lib/services/location_service.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/location_service.dart) via `geolocator`.
  - Notification permissions handled by `NotificationService`.

---

## 8. Testing Setup & Coverage

- **Test Frameworks:** `flutter_test`, `mocktail: ^1.0.0`.
- **Test Inventory (64/64 tests passing):**
  - **Unit Tests (`test/unit/`):**
    - [notification_service_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/notification_service_test.dart)
    - [reviews_repository_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/reviews_repository_test.dart)
    - [doctor_filter_provider_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/doctor_filter_provider_test.dart)
    - [onboarding_provider_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/onboarding_provider_test.dart)
    - [auth_provider_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/auth_provider_test.dart)
    - [availability_checker_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/availability_checker_test.dart)
    - [location_service_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/location_service_test.dart)
    - [reports_repository_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/reports_repository_test.dart)
    - [secure_storage_service_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/secure_storage_service_test.dart)
    - [disha_categories_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/unit/disha_categories_test.dart)
  - **Widget Tests (`test/widget/`):**
    - [disha_category_discovery_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/disha_category_discovery_test.dart)
    - [disha_details_and_features_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/disha_details_and_features_test.dart)
    - [doctor_card_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/doctor_card_test.dart)
    - [auth_recovery_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/auth_recovery_test.dart)
    - [report_doctor_sheet_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/report_doctor_sheet_test.dart)
    - [settings_screen_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/settings_screen_test.dart)
    - [app_smoke_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/app_smoke_test.dart)
    - [skeleton_loading_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/skeleton_loading_test.dart)
    - [leave_review_sheet_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/leave_review_sheet_test.dart)
    - [home_screen_components_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/home_screen_components_test.dart)
    - [verified_badge_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/verified_badge_test.dart)
    - [doctor_filter_sheet_test.dart](file:///home/me/1.%20Tanish/Doctorly/doctorly/test/widget/doctor_filter_sheet_test.dart)

- **Coverage Gaps:**
  - Instrumented integration tests (e.g. `integration_test/` running end-to-end against live Supabase backend) are not yet implemented.
  - Offline sync reconciliation (Hive mutations queue for offline booking) is not yet built (Hive currently functions as read-cache fallback for doctors).

---

## 9. Conventions, Invariants & Gotchas

### Hard Architecture Rules
1. **Never Call Supabase From Widgets:** All Supabase interaction must pass through a Repository, invoked via an `AsyncNotifier`.
2. **Access Supabase via Provider:** Always use `ref.read(supabaseClientProvider)`, never `Supabase.instance.client` in screens or widgets.
3. **No `print()` Calls:** All diagnostic logging must route through `LoggerService.instance.log` (`package:logging`).
4. **No Ad-Hoc Design Magic Numbers:** Always use [DesignTokens](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/utils/design_tokens.dart) or `Theme.of(context)`. Hardcoded colors or paddings in UI files violate team rules.
5. **No Force Unwrapping (`!`):** Never use `!` on nullable types outside test files; use `??` fallbacks, `valueOrNull`, or guard clauses.
6. **Provider AutoDispose Convention:** All remote data providers must use `.autoDispose` unless application-wide lifetime is specifically required.

### Gotchas & Sensitive Areas
- **Anonymous Data Merging:** When a guest user logs in with Google or Magic Link, `_attemptMergeIfNeeded()` triggers the `merge_anonymous_data` PostgreSQL RPC. If this RPC fails, the error is presented non-blocking via `isMerging` / `mergeError` in `BottomNavScaffold`.
- **Bootstrap Ordering in `main.dart`:** Because Android might kill apps that take too long on the native splash, `main.dart` renders a quick placeholder `CircularProgressIndicator` while initializing `LoggerService`, `NotificationService`, and `CacheService`, then switches to the full app router.
- **`--dart-define` Requirement:** The application will purposefully fail fast at startup if `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are not passed.

---

## 10. Open Questions & Undetermined Items

1. **Release Signing & Keystore:** The Android `release` build type currently points to the `debug` keystore for local testing convenience (`signingConfig = signingConfigs.getByName("debug")`). Production keystore configuration will be needed prior to Play Store deployment.
2. **Offline Mutation Queue:** While `CacheService` caches the doctor catalog to Hive for offline reads, booking appointments while offline currently throws an error rather than enqueueing an offline booking sync.
3. **Google Services JSON:** `google-services.json` is applied conditionally if present. For Google Sign-In on Android, client credentials must match the SHA-1 fingerprint of the signing key in Google Cloud Console.
