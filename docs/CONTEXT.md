# Doctorly (Disha Directory) — Architecture & Codebase Context

**Document Version:** 1.0.0  
**Last Updated:** September 2026  
**Primary Platform Targets:** Android (`compileSdk` 36, `minSdk` 21, `targetSdk` 34+), Web  
**Primary Host Architecture:** Flutter (^3.13.1) / Kotlin (2.2.20) / AGP (8.11.1)  

---

## 1. App Summary

**Doctorly** (packaged as `com.disha.directory`) is a healthcare practitioner discovery and transparency application designed primarily for patients in India seeking verified medical specialists, clinics, and hospitals. In its current Disha V1 iteration, the application acts as an authoritative, transparent medical directory that allows patients to search, filter, and review specialists across districts, inspect statutory council registrations, check real-time OPD (Outpatient Department) availability, review sub-specialties, and connect directly with doctors via phone calls, WhatsApp, or physical clinic navigation.

The target user base spans patients and their caregivers looking for trustworthy, verified medical practitioners without being forced through commercial booking paywalls. Patients can explore doctors near their physical location using device GPS (powered by spatial PostGIS calculations), examine verified vs. unverified medical council credentials, review hospital affiliations, read patient reviews, and report inaccurate profiles.

From an engineering perspective, the project is a Flutter application hosted inside a modern Android Gradle setup (Gradle Kotlin DSL, Java 17, core library desugaring, AGP 8.11.1, Kotlin 2.2.20). It connects to a Supabase backend (PostgreSQL with PostGIS, Auth, and RPC functions) and uses Riverpod for unidirectional reactive state management, Hive for offline doctor catalog caching, and GoRouter for declarative navigation.

---

## 2. Tech Stack

| Library / Tool | Version | Purpose |
|---|---|---|
| **Flutter SDK** | `^3.13.1` | Core cross-platform framework (Android & Web) |
| **Dart SDK** | `^3.13.1` | Application programming language |
| **Android Gradle Plugin (AGP)** | `8.11.1` | Android build toolchain (`android/settings.gradle.kts`) |
| **Kotlin** | `2.2.20` | Android host language & Gradle script compilation (`KOTLIN_2_0` target) |
| **Google Services Plugin** | `4.4.2` | Firebase / Google authentication services gradle plugin |
| **Desugar JDK Libs** | `2.1.4` | Java 8+ API desugaring (`com.android.tools:desugar_jdk_libs`) |
| **flutter_riverpod** | `^2.6.1` | Dependency injection & reactive state management (`AsyncNotifier` pattern, no codegen) |
| **go_router** | `^14.3.0` | Declarative routing, deep links, and `StatefulShellRoute.indexedStack` tab management |
| **supabase_flutter** | `^2.5.0` | Backend client: PostgreSQL data access, Magic Link OTP auth, PostGIS RPCs, RLS |
| **geolocator** | `^13.0.4` | GPS device location acquisition for spatial `nearby_doctors` PostGIS query |
| **google_sign_in** | `^6.2.1` | Google OAuth authentication client retrieving ID tokens for Supabase Auth |
| **google_fonts** | `^7.0.1` | Typography rendering (Plus Jakarta Sans & Inter font families) |
| **sentry_flutter** | `^8.9.0` | Production error monitoring, breadcrumbs, and crash diagnostics |
| **logging** | `^1.3.0` | Structured logging singleton (replaces raw `print` calls) |
| **cached_network_image** | `^3.4.1` | Asynchronous image loading, in-memory/disk caching for doctor avatars |
| **shimmer** | `^3.0.0` | Shimmer skeleton loading effect for cards and lists |
| **connectivity_plus** | `^7.3.1` | Real-time network state listener driving global offline banners |
| **flutter_local_notifications** | `^17.2.4` | Local Android/iOS notifications for appointment reminders |
| **timezone** | `^0.9.4` | Timezone database initialization for exact scheduled notifications |
| **flutter_secure_storage** | `^9.0.0` | Encrypted key-value store (`AndroidOptions`) for sensitive auth tokens |
| **hive / hive_flutter** | `^2.2.3` / `^1.1.0` | Fast key-value local NoSQL database for offline doctor catalog caching |
| **shared_preferences** | `^2.2.2` | Unencrypted key-value store for onboarding state and guest mode preferences |
| **url_launcher** | `^6.3.0` | Intent launcher for telephone (`tel:`), WhatsApp (`https://wa.me`), and Google Maps |
| **intl** | `^0.20.0` | Internationalization, date formatting, and time manipulation |
| **flutter_lints** | `^6.0.0` | Official Flutter static analysis rule set |
| **mocktail** | `^1.0.0` | Null-safe mocking library for unit tests |

---

## 3. Project Configuration & Build System

### 3.1 Gradle Configuration
- **Root Gradle (`android/build.gradle.kts`):**
  - Configures common repositories (`google()`, `mavenCentral()`).
  - Sets Kotlin compiler targets to `KotlinVersion.KOTLIN_2_0`.
  - Declares Google Services Gradle plugin `4.4.2` (`apply false`).
  - Redirects build outputs to the root `build/` directory.
- **Settings Gradle (`android/settings.gradle.kts`):**
  - Loads Flutter SDK path from `android/local.properties`.
  - Includes Flutter tools Gradle build (`$flutterSdkPath/packages/flutter_tools/gradle`).
  - Uses AGP `8.11.1`, Kotlin `2.2.20`, and `dev.flutter.flutter-plugin-loader` `1.0.0`.
- **Properties (`android/gradle.properties`):**
  - JVM arguments: `-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError`.
  - AndroidX enabled (`android.useAndroidX=true`).
- **App Module (`android/app/build.gradle.kts`):**
  - `namespace = "com.example.doctorly"`
  - `applicationId = "com.disha.directory"`
  - `compileSdk = 36`
  - `minSdk = flutter.minSdkVersion` (defaulting to API 21 / Android 5.0)
  - `targetSdk = flutter.targetSdkVersion` (API 34+)
  - `sourceCompatibility` & `targetCompatibility`: `JavaVersion.VERSION_17`
  - `isCoreLibraryDesugaringEnabled = true` with `desugar_jdk_libs:2.1.4`
  - Conditional application of `com.google.gms.google-services` if `google-services.json` exists.

### 3.2 Build Types, Flavors & Signing
- **Build Types:**
  - `debug`: Applies `applicationIdSuffix = ".debug"`. Results in runtime package `com.disha.directory.debug`.
  - `release`: Configured to use the debug signing key (`signingConfig = signingConfigs.getByName("debug")`) for local testing convenience. *Production keystore configuration is pending for release builds.*
- **Flavors:** No Gradle product flavors are declared; feature scoping is driven by `AppFeatures.showBooking` in Dart code.

### 3.3 Manifest & Android Package Visibility
- **Manifest (`android/app/src/main/AndroidManifest.xml`):**
  - Permissions:
    - `android.permission.INTERNET` (Network access)
    - `android.permission.ACCESS_FINE_LOCATION` (Precise GPS for PostGIS near-me search)
    - `android.permission.ACCESS_COARSE_LOCATION` (Cell/Wi-Fi location)
  - Package Visibility (`<queries>` block for Android 11+ / API 30+):
    - `tel` (Direct dialing via `url_launcher`)
    - `geo` (Map application intents)
    - `https` (Web links and WhatsApp Web / app redirects)
    - `android.intent.action.PROCESS_TEXT`

---

## 4. Architecture Overview

Doctorly follows a **Feature-First (Package-by-Feature) Clean Architecture** pattern.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                │
│                                                                             │
│  [Screens]                                                                  │
│  OnboardingScreen  AuthScreen  HomeScreen  DoctorDetailsScreen             │
│  FavoritesScreen   AppointmentsScreen   BookingScreen   SettingsScreen      │
│                                                                             │
│  [Widgets & Sheets]                                                         │
│  DoctorCard  DoctorFilterSheet  LeaveReviewSheet  ReportDoctorSheet        │
│  CategoryExplainerSheet  VerifiedExplainerSheet  VerifiedBadge  EmptyState  │
│                                                                             │
│  [Riverpod Notifiers & State (AsyncNotifier)]                               │
│  authProvider  doctorListProvider  doctorFilterProvider  locationProvider   │
│  favoritesProvider  appointmentsProvider  onboardingProvider                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Watches state / Calls methods
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            REPOSITORY LAYER                                 │
│                                                                             │
│  AuthRepository           DoctorsRepository        ReviewsRepository        │
│  AppointmentsRepository   AvailabilityRepository   FavoritesRepository      │
│  ReportsRepository        OnboardingRepository                              │
│                                                                             │
│  * Strict Error Boundary: Catches all backend errors and rethrows           │
│    strongly typed RepositoryException.                                      │
└───────────────────────┬──────────────────────────────┬──────────────────────┘
                        │                              │
                        ▼                              ▼
┌────────────────────────────────────────┐ ┌──────────────────────────────────┐
│             DATA SOURCES               │ │         SERVICES & SYSTEM        │
│                                        │ │                                  │
│ • SupabaseClient (supabaseClientProv.) │ │ • CacheService (Hive v2 cache)   │
│   - PostgreSQL tables                  │ │ • LocationService (Geolocator)   │
│   - PostGIS RPCs (nearby_doctors)      │ │ • NotificationService (Local)    │
│   - Auth & Anonymous Data Merging RPC  │ │ • SecureStorageService (AES Enc) │
│ • SharedPreferences (Onboarding flag)  │ │ • LoggerService (package:logging)│
│                                        │ │ • ErrorReporter (Sentry)         │
└────────────────────────────────────────┘ └──────────────────────────────────┘
```

### Architectural Invariants & Data Flow
1. **Unidirectional Flow:** The UI triggers actions on Riverpod notifiers (`ref.read(provider.notifier).action()`). Notifiers invoke asynchronous methods on repositories. Repositories communicate with Supabase or local caches and return pure domain models (`Doctor`, `Appointment`, `DoctorReview`). Notifiers emit immutable `AsyncValue<State>` updates watched by UI screens.
2. **Repository Boundary Rule:** Widgets and screens *never* call `Supabase.instance.client` directly. All data access is mediated through a repository injected via Riverpod (`supabaseClientProvider`).
3. **Domain Immutability:** All models under `domain/models/` are `@immutable` with JSON factory constructors and `copyWith` methods. Models do not know SQL column names or table structures.
4. **Resilience & Fallback:** `DoctorsRepository` writes successful responses to Hive (`CacheService`). When Supabase queries fail (e.g. offline mode), `DoctorsRepository` seamlessly falls back to reading from Hive and applies in-memory filters.

---

## 5. Screen Inventory & Navigation

The app utilizes `go_router` with a root navigator key (`_rootNavigatorKey`) and a `StatefulShellRoute.indexedStack` persistent bottom navigation shell (`BottomNavScaffold`).

| Screen | File / Class | Purpose | Navigation Entry Point |
|---|---|---|---|
| **Onboarding** | `lib/features/onboarding/presentation/screens/onboarding_screen.dart`<br>`OnboardingScreen` | 3-slide value proposition walkthrough; sets `hasSeenOnboarding` in SharedPreferences. | `/onboarding` (Redirect target when `hasSeenOnboarding == false`) |
| **Authentication** | `lib/features/auth/presentation/screens/auth_screen.dart`<br>`AuthScreen` | Passwordless Email OTP login, Google Sign-In, and Guest mode exploration. Includes recovery dialog. | `/login` (Redirect target when unauthenticated) |
| **Home (Shell)** | `lib/features/doctor/presentation/screens/home_screen.dart`<br>`HomeScreen` | Main doctor discovery view: search bar, 8 Disha category chips, near-me GPS button, top-rated carousel, filter sheet, doctor cards. | `/` (Shell branch 0) |
| **Favorites (Shell)** | `lib/features/favorites/presentation/screens/favorites_screen.dart`<br>`FavoritesScreen` | Saved doctors list with optimistic toggle updates. | `/favorites` (Shell branch 1) |
| **Appointments (Shell)** | `lib/features/appointments/presentation/screens/appointments_screen.dart`<br>`AppointmentsScreen` | List of upcoming/past appointments with cancellation support. *(Hidden in V1 when `AppFeatures.showBooking = false`)* | `/appointments` (Shell branch 2) |
| **Doctor Details** | `lib/features/doctor/presentation/screens/doctor_details_screen.dart`<br>`DoctorDetailsScreen` | Detailed doctor profile: verified badge, emergency banner, 7-day OPD chips, council registration, sticky bottom action bar (Call, WhatsApp, Maps), reviews, reporting. | `/doctor/:id` (Push route from cards) |
| **Booking** | `lib/features/appointments/presentation/screens/booking_screen.dart`<br>`BookingScreen` | Slot selection and appointment confirmation. *(Hidden in V1)* | `/booking/:doctorId` (Push route from doctor profile) |
| **Settings** | `lib/features/auth/presentation/screens/settings_screen.dart`<br>`SettingsScreen` | Account metadata, sign out, and full account deletion (`delete_user_account` RPC). | `/settings` (Push route from top AppBar avatar) |
| **Filter Modal** | `lib/features/doctor/presentation/widgets/doctor_filter_sheet.dart`<br>`DoctorFilterSheet` | Modal bottom sheet for minimum rating, distance radius, Delhi/Gujarat districts, and "Open Now" filter. | Modal sheet opened from `HomeScreen` |
| **Review Modal** | `lib/features/doctor/presentation/widgets/leave_review_sheet.dart`<br>`LeaveReviewSheet` | Star rating (1–5) and comment submission for doctors. | Modal sheet opened from `DoctorDetailsScreen` |
| **Report Modal** | `lib/features/doctor/presentation/widgets/report_doctor_sheet.dart`<br>`ReportDoctorSheet` | Medical board/profile report submission sheet. | Modal sheet opened from `DoctorDetailsScreen` |
| **Verification Info** | `lib/features/doctor/presentation/widgets/verified_explainer_sheet.dart`<br>`VerifiedExplainerSheet` | Transparency sheet explaining medical council checks. | Modal sheet opened from verification badge |
| **Category Info** | `lib/features/doctor/presentation/widgets/category_explainer_sheet.dart`<br>`CategoryExplainerSheet` | Transparency sheet explaining what symptoms belong to a category. | Modal sheet opened from category chips |

---

## 6. Module Dependency Map

The codebase is structured as a modular monolithic single module. Features are decoupled horizontally; shared infrastructure lives in cross-cutting directories:

```text
lib/
├── config/
│   └── app_features.dart               (Feature flag: showBooking = false)
├── env.dart                            (Compile-time environment validation via --dart-define)
├── providers/                          (Core dependency injection)
│   ├── supabase_client_provider.dart   (Injects SupabaseClient)
│   ├── connectivity_provider.dart      (Injects Stream<ConnectivityResult>)
│   └── error_reporter_provider.dart    (Injects ErrorReporter)
├── services/                           (Infrastructure singletons)
│   ├── cache_service.dart              (Hive local offline database)
│   ├── secure_storage_service.dart     (FlutterSecureStorage AES)
│   ├── location_service.dart           (Geolocator GPS)
│   ├── notification_service.dart       (Local notifications & reminders)
│   ├── logger.dart                     (Logging singleton)
│   └── error_reporter.dart             (Sentry client)
├── utils/                              (Tokens & helpers)
│   ├── app_router.dart                 (GoRouter route declarations)
│   ├── design_tokens.dart              (Central color/spacing/radius design system)
│   ├── repository_exception.dart       (Standardized error hierarchy)
│   ├── error_localizer.dart            (Humanized error strings)
│   ├── availability_checker.dart       (5-state OPD calculation)
│   ├── disha_categories.dart           (8 patient categories & service slug mapping)
│   └── doctor_strings.dart             (Localized strings & medical disclaimers)
└── features/                           (Domain slices)
    ├── onboarding/ ────► (uses shared_preferences)
    ├── auth/       ────► (uses supabaseClient, secureStorage, google_sign_in)
    ├── doctor/     ────► (uses supabaseClient, cache_service, location_service, auth)
    ├── favorites/  ────► (uses supabaseClient, doctor feature)
    └── appointments/ ──► (uses supabaseClient, notification_service, doctor feature)
```

---

## 7. Data Layer & Backend Endpoints

### 7.1 Backend Infrastructure
- **Provider:** Supabase (PostgreSQL 15+ with PostGIS `GEOGRAPHY(Point, 4326)`).
- **Client Configuration:**
  - Base URL: `Env.supabaseUrl` (passed via `--dart-define=SUPABASE_URL=...`)
  - Publishable Anon Key: `Env.supabasePublishableKey` (passed via `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`)
- **Authentication:** Supabase GoTrue Auth supporting Magic Link Email OTP (`verifyOTP`), Google OAuth ID tokens (`signInWithIdToken`), and Anonymous guest sessions (`signInAnonymously`).

### 7.2 Database Schema & Endpoints Referenced

| Table / RPC | Methods Used | Purpose |
|---|---|---|
| `public.doctors` | `SELECT`, `.gte()`, `.eq()`, `.order()`, `.limit()`, `.or()` | Doctor profiles, ratings, council registrations, 7-day OPD hours, location. |
| `public.doctor_services` | `SELECT` (joined with `services(slug, name)`) | Junction mapping doctors to Disha service specialties (`status`: yes/no/unknown). |
| `public.services` | `SELECT` (via nested PostgREST join) | Master medical services taxonomy lookup (11 medical sub-specialties). |
| `public.doctor_reviews` | `SELECT`, `INSERT` | Patient reviews and star ratings. |
| `public.reports` | `INSERT` | Flagging inaccurate profiles, credentials, or closed clinics. |
| `public.favorites` | `SELECT`, `INSERT`, `DELETE` | User saved doctors junction. |
| `public.appointments` | `SELECT`, `INSERT`, `UPDATE` | Appointment bookings and cancellations. |
| `public.availability_slots`| `SELECT` | Future doctor booking slots. |
| `RPC: nearby_doctors` | `POST /rest/v1/rpc/nearby_doctors` | PostGIS spatial query calculating distance using `ST_Distance` / `ST_DWithin`. |
| `RPC: merge_anonymous_data` | `POST /rest/v1/rpc/merge_anonymous_data` | Migrates anonymous guest favorites and appointments to a newly authenticated user ID. |
| `RPC: delete_user_account` | `POST /rest/v1/rpc/delete_user_account` | Deletes user data and triggers user account removal. |

---

## 8. Cross-Cutting Concerns

### 8.1 Permissions
1. **Location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`):**
   - Declared in `android/app/src/main/AndroidManifest.xml`.
   - Requested at runtime in `lib/services/location_service.dart` via `Geolocator.checkPermission()` and `Geolocator.requestPermission()`.
   - Throws strongly typed `LocationException` if disabled or denied; displays user-friendly retry SnackBar in `HomeScreen`.
2. **Notifications (`POST_NOTIFICATIONS` on Android 13+):**
   - Requested during startup in `NotificationService.initialize()` via `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`.

### 8.2 Error Handling & Logging
- **Logging Rule:** `print()` is strictly forbidden across the codebase. All logging routes through `LoggerService.instance.log` (`package:logging`).
- **Typed Error Hierarchy:** All network and database calls catch raw exceptions and convert them into `RepositoryException` with Kind categorization (`network`, `unauthorized`, `notFound`, `server`, `unknown`) in `lib/utils/repository_exception.dart`.
- **User-Facing Errors:** Screen notifiers map exceptions through `localizeError(e)` in `lib/utils/error_localizer.dart` to show understandable feedback rather than raw stack traces.
- **Global Error Boundaries:**
  - `FlutterError.onError`: Traps framework errors, logs to `LoggerService`, and reports to Sentry.
  - `runZonedGuarded`: Encapsulates `main()` to catch unhandled asynchronous zone errors.
  - `ErrorBoundary`: Widget wrapping root `MaterialApp` to display a graceful fallback screen instead of a red error screen.

### 8.3 Design Tokens & Theming
- Centralized in `lib/utils/design_tokens.dart`.
- Ad-hoc hex colors, inline margins, or arbitrary border radii are strictly forbidden in UI files; all styling references `DesignTokens` or `Theme.of(context)`.

---

## 9. Quality, Testing & Tooling

### 9.1 Test Suite Status (67/67 Passing)
The test suite consists of unit and widget tests:
- **Unit Tests (`test/unit/`):**
  - `availability_checker_test.dart` (5-state OPD calculation)
  - `cache_service_test.dart` (Hive schema versioning, cold cache fallback)
  - `disha_categories_test.dart` (Category matching and mapping)
  - `location_service_test.dart` (Geolocator exception handling)
  - `notification_service_test.dart` (Scheduled notification calculations)
  - `reports_repository_test.dart` & `reviews_repository_test.dart`
  - `secure_storage_service_test.dart`
- **Widget Tests (`test/widget/`):**
  - `disha_details_and_features_test.dart` (Medical disclaimers, OPD chips, booking visibility toggle)
  - `disha_category_discovery_test.dart` (8 category chips, info sheet triggers)
  - `doctor_filter_sheet_test.dart` (Sliders, district picker, reset/apply)
  - `doctor_card_test.dart` & `verified_badge_test.dart`
  - `settings_screen_test.dart` (Sign out & account deletion dialogs)
  - `auth_recovery_test.dart` (OTP recovery flow)
  - `skeleton_loading_test.dart` & `leave_review_sheet_test.dart`

### 9.2 Tooling & Standalone Import CLI
- `tooling/doctor_import/`: Contains a dedicated CLI tool (`bin/import_doctors.dart`) and parser (`lib/doctor_parser.dart`) for bulk-importing, normalizing phone numbers to E.164 format, and upserting TSV datasets (`docs/data/doctorly_neuro_test_data.tsv` superseding `docs/data/doctorly_test_data.tsv`) into Supabase.

---

## 10. Key File Paths

| Responsibility | File Path |
|---|---|
| **App Entry Point & Zone Setup** | [`lib/main.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/main.dart) |
| **Navigation & Route Guards** | [`lib/utils/app_router.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/utils/app_router.dart) |
| **Design Tokens & Theme** | [`lib/utils/design_tokens.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/utils/design_tokens.dart) |
| **Environment Configuration** | [`lib/env.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/env.dart) |
| **Feature Flags** | [`lib/config/app_features.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/config/app_features.dart) |
| **Supabase Client Provider** | [`lib/providers/supabase_client_provider.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/providers/supabase_client_provider.dart) |
| **Auth Repository (Google / OTP)** | [`lib/features/auth/data/repositories/auth_repository.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/auth/data/repositories/auth_repository.dart) |
| **Doctors Repository & Cache** | [`lib/features/doctor/data/repositories/doctors_repository.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/features/doctor/data/repositories/doctors_repository.dart) |
| **Offline Cache Service (Hive)** | [`lib/services/cache_service.dart`](file:///home/me/1.%20Tanish/Doctorly/doctorly/lib/services/cache_service.dart) |
| **Android Manifest** | [`android/app/src/main/AndroidManifest.xml`](file:///home/me/1.%20Tanish/Doctorly/doctorly/android/app/src/main/AndroidManifest.xml) |
| **Android App Buildscript** | [`android/app/build.gradle.kts`](file:///home/me/1.%20Tanish/Doctorly/doctorly/android/app/build.gradle.kts) |
| **Supabase V1 Migration** | [`supabase/migrations/20260918080000_disha_directory_expansion.sql`](file:///home/me/1.%20Tanish/Doctorly/doctorly/supabase/migrations/20260918080000_disha_directory_expansion.sql) |
| **Supabase Country/State Migration** | [`supabase/migrations/20260918090000_add_country_state.sql`](file:///home/me/1.%20Tanish/Doctorly/doctorly/supabase/migrations/20260918090000_add_country_state.sql) |
| **Neurosurgery Test Dataset** | [`docs/data/doctorly_neuro_test_data.tsv`](file:///home/me/1.%20Tanish/Doctorly/doctorly/docs/data/doctorly_neuro_test_data.tsv) |

---

## 11. Known Issues, Technical Debt & Risks

1. **[RESOLVED] Active Database Schema Gap (`doctor_services` / `services` & Neurosurgery Dataset):**
   - **Resolution:** Applied `20260918080000_disha_directory_expansion.sql`, `20260918090000_add_country_state.sql`, and `supabase/replace_dataset.sql`.
   - **Status:** All 100 neurosurgery doctors (`TEST-DR-001` through `TEST-DR-100`) and associated `public.services` / `public.doctor_services` relationships are active in the live Supabase project (`ygclosmgqwfjaedwyqxs.supabase.co`).
   - PostgREST queries replaying all `DoctorsRepository` query shapes (`fetchAll`, `fetchById`, `fetchTopRated`, `searchDoctors`) and RPC `nearby_doctors` return HTTP 200 with zero PGRST200 errors.
   - Client Hive cache schema bumped to version 3 in `CacheService` to invalidate stale cached records on existing devices.

2. **Android Release Signing Keystore:**
   - In `android/app/build.gradle.kts`, the `release` build type is currently configured to sign with the `debug` keystore:
     ```kotlin
     signingConfig = signingConfigs.getByName("debug")
     ```
   - Prior to uploading to Google Play Console, a production release keystore and environment-driven `key.properties` must be configured.

3. **CI/CD Pipeline Missing:**
   - There is no `.github/workflows` directory or CI pipeline configured for automated linting, testing, and APK builds on pull requests.

4. **Offline Mutation Queue:**
   - While `CacheService` caches doctor listings to Hive for offline reads, actions like submitting reviews or reporting doctors do not queue mutations offline; they fail immediately if connectivity is lost.

---

## 12. Walkthrough & Clarifying Inquiries

### Observations & Non-Standard Findings
- **Dual Verification Architecture:** The data model accommodates both legacy boolean `is_verified` and granular tri-state `verification_status` (`'unverified'`, `'partially_verified'`, `'verified'`).
- **Initial Native Loading Placeholder:** `main()` starts by mounting an immediate `MaterialApp` with a `CircularProgressIndicator` before completing asynchronous initialization of Hive, logging, and notifications, then transitions to the full `GoRouter`. This was designed to prevent Android OS watchdog crashes during heavy startup tasks.
- **V1 Scope Toggling via Code:** The codebase contains complete, tested implementations of appointment booking (`appointments/` feature, `AppointmentsScreen`, `BookingScreen`, `AvailabilityRepository`, `AppointmentsRepository`), but deliberately toggles them off via `AppFeatures.showBooking = false` to focus V1 solely on discovery and direct doctor contact.

### Clarifying Questions for the Team
1. **Supabase Migration Deployment:** Is there a scheduled window or administrative access to apply `supabase/migrations/20260918080000_disha_directory_expansion.sql` to the remote Supabase project?
2. **Release Keystore Setup:** Should a standardized Gradle `key.properties` configuration be established for Google Play signing, or will CI/CD handle signing via repository secrets?
3. **Google Services Config:** Should a production `google-services.json` be provisioned and tracked (or securely injected via CI) for Android Google Sign-In and notifications?
