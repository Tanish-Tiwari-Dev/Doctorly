# Project Architecture Report: Doctorly

## A. Project Overview

- **Application Name:** Doctorly
- **Description:** A mobile and web application built with Flutter for discovering medical specialists, viewing doctor profiles, booking appointments, managing favorite doctors, and handling user authentication (Email OTP, Google OAuth, and Guest mode) with offline onboarding persistence and location-based doctor search.
- **Tech Stack:**
  - **Framework / SDK:** Flutter `^3.13.1` (Android + Web targets), Dart SDK `^3.13.1`
  - **State Management:** `flutter_riverpod ^2.6.1` (AsyncNotifier / Notifier pattern without code generation)
  - **Routing:** `go_router ^14.3.0` (StatefulShellRoute.indexedStack, nested shell routing, auth guard redirects)
  - **Backend / Database:** `supabase_flutter ^2.5.0` (PostgreSQL + PostGIS RPCs)
  - **Location Services:** `geolocator ^13.0.2`
  - **Typography & UI Styling:** `google_fonts ^7.0.1` (Inter / Plus Jakarta Sans), Material 3 ThemeData
  - **Observability & Logging:** `logging ^1.3.0` (LoggerService singleton), `sentry_flutter ^8.9.0` (Error boundary reporting)
  - **Persistence & Media:** `shared_preferences ^2.2.2`, `cached_network_image ^3.4.1`, `shimmer ^3.0.0`
  - **Authentication:** `google_sign_in ^6.2.1`, Supabase Auth (Email OTP + Anonymous guest auth)
- **Current `flutter analyze` Status:** `No issues found!` (Clean static analysis, zero warnings/errors).

---

## B. Architectural Paradigm

- **Pattern in Use:** **Layer-First Architecture** with Repository Pattern.
  - The codebase is partitioned by technical responsibility (`models/`, `providers/`, `repositories/`, `screens/`, `services/`, `utils/`, `widgets/`).
- **Dependency Flow Rules (as defined in AGENTS.md & implemented):**
  - **Presentation Layer (`screens/`, `widgets/`):** Reactively watches Riverpod providers. UI widgets trigger business actions strictly through provider notifiers.
  - **State Management Layer (`providers/`):** Encapsulates state using `AsyncNotifier` and `Notifier`. Manages business logic and interacts with the Repository Layer.
  - **Data Layer (`repositories/`):** Serves as an abstraction layer between providers and external data sources (Supabase RPCs, database tables, `SharedPreferences`). Maps raw JSON rows to immutable Domain Models.
  - **Service Layer (`services/`):** Provides global infrastructure singletons (logging via `logging`, location permissions/position via `geolocator`, and error monitoring via `Sentry`).
  - **Domain / Models (`models/`):** Immutable data entities (`@immutable` classes with `copyWith` and factory `fromJson` constructors). Models contain no database logic.

```
+-------------------------------------------------------------------+
|                        Presentation Layer                         |
|                    (screens/ & widgets/)                          |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                      State Management Layer                       |
|                          (providers/)                             |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                            Data Layer                             |
|                          (repositories/)                          |
+-------------------------------------------------------------------+
                 /                                 \
                v                                   v
+-------------------------------+   +-------------------------------+
|        Backend / Client       |   |         Local Storage         |
|  (supabaseClientProvider)     |   |     (SharedPreferences)       |
+-------------------------------+   +-------------------------------+
```

---

## C. Directory & File Breakdown

### Directory Responsibilities

- **`lib/`**: Root source folder holding application entrypoint (`main.dart`) and runtime environment configuration (`env.dart`).
- **`lib/models/`**: Domain models representing domain entities (`Appointment`, `Doctor`, `Specialty`).
- **`lib/providers/`**: Riverpod providers and `AsyncNotifier` / `Notifier` classes managing UI state, auth flows, filtering, and data fetching.
- **`lib/repositories/`**: Repository abstractions handling database queries via Supabase or local persistence via `SharedPreferences`.
- **`lib/screens/`**: High-level screen components representing distinct application routes.
- **`lib/services/`**: Cross-cutting infrastructure singletons for logging, error reporting, and device geolocation.
- **`lib/utils/`**: Utilities for routing (`app_router.dart`), design system colors (`app_colors.dart`), repository exception handling, and error localization.
- **`lib/widgets/`**: Shared presentation components, skeletons, layout scaffolds, and error boundary wrappers.

---

### Detailed File Breakdown

#### Root Directory (`lib/`)

##### `lib/main.dart`
- **Role:** Application bootstrap entrypoint. Initializes logger, validates configuration (`Env`), bootstraps Supabase, triggers initial anonymous guest authentication, configures global error handlers (FlutterError & Sentry/Zone), and runs `MainApp` wrapped in `ErrorBoundary` and `UncontrolledProviderScope`.
- **Key Exports / Classes:** `main()`, `MainApp` (`StatelessWidget`).

##### `lib/env.dart`
- **Role:** Manages compile-time environment configuration retrieved via `--dart-define` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SENTRY_DSN`).
- **Key Exports / Classes:** `ConfigurationException`, `Env`.

---

#### Models (`lib/models/`)

##### `lib/models/appointment.dart`
- **Role:** Immutable representation of a doctor appointment, including parsing logic for `AppointmentStatus` enums.
- **Key Exports / Classes:** `AppointmentStatus` (enum: `pending`, `confirmed`, `cancelled`), `Appointment`.

##### `lib/models/doctor.dart`
- **Role:** Immutable entity representing doctor details, qualifications, ratings, geolocation distances, expertise maps, and availability flags. Includes `copyWith`, `fromJson`, `toJson`, and equality operators.
- **Key Exports / Classes:** `Doctor`.

##### `lib/models/specialty.dart`
- **Role:** Enum defining medical specialties with human-readable labels and associated Material icons.
- **Key Exports / Classes:** `Specialty` (enum: `cardiology`, `dermatology`, `pediatrics`, `orthopedics`, `generalPractice`, `dentistry`).

---

#### Providers (`lib/providers/`)

##### `lib/providers/appointments_provider.dart`
- **Role:** `AsyncNotifier` managing user appointments, providing async operations for fetching, creating, and cancelling appointments.
- **Key Exports / Classes:** `AppointmentsNotifier`, `appointmentsProvider`.

##### `lib/providers/auth_provider.dart`
- **Role:** `AsyncNotifier` managing authentication state (`AuthState`), stream listening on auth changes, email OTP delivery/verification, Google sign-in, guest sign-in, account sign-out, account deletion, and guest data merging.
- **Key Exports / Classes:** `AuthState`, `humanizeAuthError()`, `AuthNotifier`, `authProvider`, `currentUserIdProvider`, `isMergingProvider`.

##### `lib/providers/booking_provider.dart`
- **Role:** `Notifier` managing interactive state during appointment booking (selected date & time validation).
- **Key Exports / Classes:** `BookingState`, `BookingNotifier`, `bookingProvider`.

##### `lib/providers/doctor_provider.dart`
- **Role:** `AsyncNotifier` and derived Riverpod providers managing doctor listing, top-rated doctor sorting, specialty selection, debounced search query state, location filter results, and filtered doctor lists.
- **Key Exports / Classes:** `DoctorsNotifier`, `doctorListProvider`, `doctorByIdProvider`, `topRatedDoctorsProvider`, `selectedSpecialtyProvider`, `nearbyResultsProvider`, `SearchQueryNotifier`, `searchQueryProvider`, `filteredDoctorsProvider`.

##### `lib/providers/error_reporter_provider.dart`
- **Role:** Riverpod provider returning the global `ErrorReporter` instance (`SentryErrorReporter`).
- **Key Exports / Classes:** `errorReporterProvider`.

##### `lib/providers/favorites_provider.dart`
- **Role:** `AsyncNotifier` managing user favorite doctor IDs (`Set<String>`) with optimistic state updates and database synchronization.
- **Key Exports / Classes:** `FavoritesNotifier`, `favoritesProvider`.

##### `lib/providers/location_provider.dart`
- **Role:** Riverpod provider for obtaining the `LocationService` instance.
- **Key Exports / Classes:** `locationServiceProvider`.

##### `lib/providers/onboarding_provider.dart`
- **Role:** `AsyncNotifier` managing onboarding completion state and persisting completion flag via `OnboardingRepository`.
- **Key Exports / Classes:** `OnboardingNotifier`, `onboardingProvider`.

##### `lib/providers/supabase_client_provider.dart`
- **Role:** Riverpod provider supplying the singleton `SupabaseClient` instance after verifying environment configuration.
- **Key Exports / Classes:** `supabaseClientProvider`.

---

#### Repositories (`lib/repositories/`)

##### `lib/repositories/appointments_repository.dart`
- **Role:** Encapsulates Supabase queries for the `appointments` table (fetching, inserting, updating status). Maps Postgrest exceptions to `RepositoryException`.
- **Key Exports / Classes:** `AppointmentsRepository`, `appointmentsRepositoryProvider`.

##### `lib/repositories/auth_repository.dart`
- **Role:** Wraps Supabase Auth API calls (`signInWithOtp`, `verifyOTP`, `signInWithIdToken`, `signInAnonymously`, `signOut`, `merge_anonymous_data` RPC, and `delete_user_account` RPC).
- **Key Exports / Classes:** `AuthRepository`, `authRepositoryProvider`.

##### `lib/repositories/availability_repository.dart`
- **Role:** Fetches available time slots for doctors from the `availability_slots` Supabase table.
- **Key Exports / Classes:** `AvailabilityRepository`, `availabilityRepositoryProvider`.

##### `lib/repositories/doctors_repository.dart`
- **Role:** Fetches doctor records from the `doctors` table and executes `nearby_doctors` PostGIS RPC calls.
- **Key Exports / Classes:** `DoctorsRepository`, `doctorRepositoryProvider`.

##### `lib/repositories/favorites_repository.dart`
- **Role:** Manages user favorites persistence in the `favorites` table (fetching, adding, removing doctor IDs).
- **Key Exports / Classes:** `FavoritesRepository`, `favoritesRepositoryProvider`.

##### `lib/repositories/onboarding_repository.dart`
- **Role:** Manages onboarding completion status using `SharedPreferences`.
- **Key Exports / Classes:** `OnboardingRepository`, `onboardingRepositoryProvider`.

---

#### Screens (`lib/screens/`)

##### `lib/screens/appointments_screen.dart`
- **Role:** Displays user's booked appointments with status badges (Pending, Confirmed, Cancelled) and cancellation actions.
- **Key Exports / Classes:** `AppointmentsScreen`.

##### `lib/screens/auth_screen.dart`
- **Role:** Authentication view supporting two-step Email OTP (request code & verify 8-digit PIN), Google OAuth button, Guest Sign-In, and Account Recovery modal dialog.
- **Key Exports / Classes:** `AuthScreen`.

##### `lib/screens/booking_screen.dart`
- **Role:** Interactive appointment scheduling view showing doctor info, available time slot chips (via `availabilitySlotsProvider`), and booking confirmation.
- **Key Exports / Classes:** `BookingScreen`, `availabilitySlotsProvider`.

##### `lib/screens/doctor_details_screen.dart`
- **Role:** Detailed doctor view presenting hero image header, rating, qualifications, availability status, background bio, expertise list, contact info, favorite toggle, and booking CTA.
- **Key Exports / Classes:** `DoctorDetailsScreen`.

##### `lib/screens/favorites_screen.dart`
- **Role:** Displays list of doctors bookmarked by the user.
- **Key Exports / Classes:** `FavoritesScreen`.

##### `lib/screens/home_screen.dart`
- **Role:** Primary dashboard featuring search input, specialty chip filter bar, top-rated doctor horizontal carousel, location-based "Near Me" trigger, settings navigation, and doctor list.
- **Key Exports / Classes:** `HomeScreen`.

##### `lib/screens/onboarding_screen.dart`
- **Role:** 3-page onboarding carousel showcasing key app features with page indicators, skip action, and completion flow.
- **Key Exports / Classes:** `OnboardingScreen`.

##### `lib/screens/settings_screen.dart`
- **Role:** Settings screen displaying user account details, guest/authenticated status, sign-out button, and account deletion confirmation dialog.
- **Key Exports / Classes:** `SettingsScreen`.

---

#### Services (`lib/services/`)

##### `lib/services/error_reporter.dart`
- **Role:** Abstraction interface and Sentry implementation for capturing uncaught exceptions and reporting stack traces with contextual scope.
- **Key Exports / Classes:** `ErrorReporter`, `SentryErrorReporter`.

##### `lib/services/location_service.dart`
- **Role:** Handles device location permissions and retrieves latitude/longitude coordinates using `geolocator`.
- **Key Exports / Classes:** `LocationService`.

##### `lib/services/logger.dart`
- **Role:** Singleton wrapper around `package:logging` configuring root logger levels, hierarchical logging, and formatted output.
- **Key Exports / Classes:** `LoggerService`.

---

#### Utilities (`lib/utils/`)

##### `lib/utils/app_colors.dart`
- **Role:** Design system color palette definitions (primary, background, text, semantic status colors).
- **Key Exports / Classes:** `AppColors`.

##### `lib/utils/app_router.dart`
- **Role:** Configures `GoRouter` with `StatefulShellRoute.indexedStack` for bottom navigation tabs, top-level detail/booking routes, and automatic auth/onboarding guard redirects.
- **Key Exports / Classes:** `buildAppRouter()`.

##### `lib/utils/error_localizer.dart`
- **Role:** Translates `RepositoryException` kinds into user-friendly error messages.
- **Key Exports / Classes:** `localizeError()`.

##### `lib/utils/repository_exception.dart`
- **Role:** Custom exception type and error classification helper categorizing network, notFound, unauthorized, and unknown errors.
- **Key Exports / Classes:** `RepositoryExceptionKind`, `RepositoryException`, `classifyError()`.

---

#### Widgets (`lib/widgets/`)

##### `lib/widgets/bottom_nav_scaffold.dart`
- **Role:** Responsive navigation scaffold rendering a bottom `NavigationBar` on mobile and `NavigationRail` on wide screen sizes, with an anonymous data merge progress banner.
- **Key Exports / Classes:** `BottomNavScaffold`.

##### `lib/widgets/doctor_card.dart`
- **Role:** Reusable doctor card displaying doctor avatar, name, rating, specialty, distance, availability tag, and favorite toggle button. Supports regular and compact layouts.
- **Key Exports / Classes:** `DoctorCard`.

##### `lib/widgets/doctor_card_skeleton.dart`
- **Role:** Shimmer loading placeholder for `DoctorCard`.
- **Key Exports / Classes:** `DoctorCardSkeleton`.

##### `lib/widgets/empty_state.dart`
- **Role:** Reusable empty / error state layout with icon, title, subtitle, and retry button.
- **Key Exports / Classes:** `EmptyState`.

##### `lib/widgets/error_boundary.dart`
- **Role:** Consumer widget wrapping the app root to catch Flutter framework errors and render a graceful error fallback screen.
- **Key Exports / Classes:** `ErrorBoundary`.

---

### Feature-First & Deletability Analysis

- **Current Organization:** The codebase uses a **Layer-First** directory structure (`models/`, `providers/`, `repositories/`, `screens/`, `widgets/`).
- **Deletability Assessment:**
  - Standard Feature-First Clean Architecture organizes code by self-contained feature folders (e.g. `lib/features/doctor/presentation/`, `lib/features/doctor/domain/`, `lib/features/doctor/data/`).
  - In Doctorly's current layer-first organization, removing a feature (such as "Favorites") requires touching multiple distinct directories (`lib/screens/favorites_screen.dart`, `lib/providers/favorites_provider.dart`, `lib/repositories/favorites_repository.dart`).
  - While files are clearly named and modularized, deleting a feature requires manual cross-folder cleanups rather than simply deleting a feature directory.

---

## D. State Management & Data Flow

### Approach
State management is built on **Riverpod 2.x** using explicit `AsyncNotifier` and `Notifier` implementations (no code generation / build_runner required).

### Data Flow Concrete Example: Appointment Booking

The diagram below illustrates the end-to-end data flow when a user books an appointment:

```
[ UI Layer ]               [ State Management ]                 [ Data Layer ]                  [ Supabase ]
BookingScreen           AppointmentsNotifier / Provider    AppointmentsRepository          Supabase Database
     |                                  |                                 |                             |
     |--- 1. Confirm Booking ---------->|                                 |                             |
     |   (create doctorId, scheduled)   |                                 |                             |
     |                                  |--- 2. create(userId, ...) ----->|                             |
     |                                  |                                 |--- 3. .from('appointments') |
     |                                  |                                 |       .insert(...) -------->|
     |                                  |                                 |                             |
     |                                  |                                 |<-- 4. Json Response --------|
     |                                  |                                 |                             |
     |                                  |                                 |--- 5. Appointment.fromJson  |
     |                                  |<-- 6. Returns Appointment ------|                             |
     |                                  |                                 |                             |
     |                                  |--- 7. invalidateSelf() -------->| (re-fetches user list)      |
     |                                  |                                 |                             |
     |<-- 8. Emits AsyncValue.data -----|                                 |                             |
     |    & Navigate to /appointments   |                                 |                             |
```

1. **User Action (UI):** User selects a time slot and taps "Confirm Booking" in `BookingScreen` (`lib/screens/booking_screen.dart`).
2. **Notifier Dispatch:** `BookingScreen` invokes `ref.read(appointmentsProvider.notifier).create(doctorId, scheduledFor)`.
3. **Repository Execution:** `AppointmentsNotifier` reads `currentUserIdProvider` and delegates to `AppointmentsRepository.create(userId, doctorId, scheduledFor)` (`lib/repositories/appointments_repository.dart`).
4. **Backend Query:** `AppointmentsRepository` uses the injected `SupabaseClient` to perform an `insert` query on the `appointments` table.
5. **Data Transformation:** `AppointmentsRepository` maps the returning JSON map into an immutable `Appointment` domain object via `Appointment.fromJson()`.
6. **State Mutation & Invalidation:** Upon successful insertion, `AppointmentsNotifier` calls `ref.invalidateSelf()`, which automatically triggers a refetch of the user's appointment list via `AppointmentsRepository.fetchForUser(userId)`.
7. **Reactive UI Update:** The Riverpod framework notifies UI subscribers watching `appointmentsProvider`, updating `AppointmentsScreen` automatically with the newly booked appointment.

---

## E. Adherence Audit (AGENTS.md Compliance)

### Summary Table

| Rule Category | Requirement | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Backend Calls** | All Supabase access via Repositories | ✅ Compliant | All Supabase access strictly encapsulated inside Repositories. `HomeScreen._handleNearMe()` delegates to `DoctorsRepository.fetchNearby()`. |
| **UI Styling** | No inline `GoogleFonts.inter()` styles | ✅ Compliant | All text styles centralized in `ThemeData.textTheme` using `GoogleFonts.plusJakartaSans` & `GoogleFonts.inter`. Widgets consume `Theme.of(context).textTheme`. |
| **Logging** | No `print()` calls in codebase | ✅ Compliant | Zero `print()` statements found. All logging flows through `LoggerService.instance.log`. |
| **State Management**| AsyncNotifier pattern without codegen | ✅ Compliant | All async state is managed via `AsyncNotifierProvider` / `AsyncNotifier`. |
| **Repository Layer**| Required between Notifiers & Supabase | ✅ Compliant | Repositories exist for all entities (`Auth`, `Doctors`, `Appointments`, `Favorites`, `Availability`, `Onboarding`). |
| **Model Immutability**| Immutable models with `copyWith` | ✅ Compliant | `Doctor`, `Appointment`, and `BookingState` are annotated with `@immutable` and supply `copyWith`. |
| **Routing** | GoRouter with shell routes & detail routes | ✅ Compliant | `buildAppRouter` uses `StatefulShellRoute.indexedStack` for tabs and top-level routes for details. |
| **Error Handling** | Surface errors via `AsyncValue.error` | ✅ Compliant | Exceptions are classified into `RepositoryException` and localized via `localizeError()`. |
| **Null Safety** | Prefer `??`, early returns, no `!` outside tests | ✅ Compliant | No forced non-null assertions (`!`) found in production code. |
| **Code Structure** | File naming snake_case, 1 screen per file | ✅ Compliant | Clean naming conventions throughout `lib/`. |

---

### Actionable Audit Notes

All identified architectural boundary violations and hardcoded text styling instances have been resolved. The codebase is fully compliant with the guidelines outlined in `AGENTS.md`.
