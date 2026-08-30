# Doctorly — Comprehensive Project Architecture & Map

**Version:** 0.1.0+1  
**Flutter SDK:** ^3.13.1 (Android + Web targets)  
**Backend:** Supabase (PostgreSQL + PostGIS spatial functions)  
**State Management:** `flutter_riverpod` ^2.6.1 (`AsyncNotifier` pattern)  
**Router:** `go_router` ^14.3.0 (`StatefulShellRoute.indexedStack`)  

---

## 1. Architecture Overview

Doctorly follows a clean, layered architecture with strict separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (Screens)                     │
│  OnboardingScreen | AuthScreen | HomeScreen | DoctorDetails │
│         FavoritesScreen | AppointmentsScreen | Booking      │
└──────────────────────────────┬──────────────────────────────┘
                               │ Watches / Reads
┌──────────────────────────────▼──────────────────────────────┐
│                  State Management (Riverpod)               │
│  authProvider | doctorListProvider | appointmentsList       │
│    favoritesProvider | locationProvider | bookingProvider   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Calls
┌──────────────────────────────▼──────────────────────────────┐
│                    Repository Layer                         │
│  AuthRepo | DoctorsRepo | AppointmentsRepo | Availability  │
│                     FavoritesRepo                           │
└──────────────────────────────┬──────────────────────────────┘
                               │ Uses
┌──────────────────────────────▼──────────────────────────────┐
│              Data Services & Supabase Client                │
│       supabaseClientProvider | LoggerService | SharedPreferences │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure Map
```
lib/
├── env.dart                        # Compile-time environment configuration (`--dart-define`)
├── main.dart                       # App entry point, Zone error handling, app initialization
├── models/                         # Immutable data models with `copyWith` and JSON parsing
│   ├── appointment.dart
│   ├── doctor.dart
│   └── specialty.dart
├── providers/                      # Riverpod AsyncNotifiers & Providers
│   ├── appointments_provider.dart
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   ├── doctor_provider.dart
│   ├── error_reporter_provider.dart
│   ├── favorites_provider.dart
│   ├── location_provider.dart
│   └── supabase_client_provider.dart
├── repositories/                   # Data access layer (Supabase tables & RPC calls)
│   ├── appointments_repository.dart
│   ├── auth_repository.dart
│   ├── availability_repository.dart
│   ├── doctors_repository.dart
│   └── favorites_repository.dart
├── screens/                        # UI screens
│   ├── appointments_screen.dart
│   ├── auth_screen.dart
│   ├── booking_screen.dart
│   ├── doctor_details_screen.dart
│   ├── favorites_screen.dart
│   ├── home_screen.dart
│   └── onboarding_screen.dart
├── services/                       # Infrastructure singletons & services
│   ├── error_reporter.dart         # Sentry integration & fallback logging
│   ├── location_service.dart       # Geolocator location fetching
│   └── logger.dart                 # Package logging wrapper singleton
├── utils/                          # Routing, theme tokens, error localizer
│   ├── app_colors.dart             # Color constants and design tokens
│   ├── app_router.dart             # GoRouter setup with StatefulShellRoute
│   ├── error_localizer.dart        # Friendly error message translation
│   └── repository_exception.dart   # Standardized repository exception wrapper
└── widgets/                        # Reusable UI widgets
    ├── bottom_nav_scaffold.dart    # Bottom navigation bar container
    ├── doctor_card.dart            # Doctor listing card
    ├── doctor_card_skeleton.dart   # Shimmer skeleton loader
    ├── empty_state.dart            # Reusable empty state view
    └── error_boundary.dart         # Custom error widget boundary
```

---

## 2. Dependencies & Tech Stack

Declared in `pubspec.yaml`:

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | `^2.6.1` | Reactive state management & dependency injection |
| `go_router` | `^14.3.0` | Declarative routing with shell route support |
| `supabase_flutter` | `^2.5.0` | PostgreSQL DB, Auth, PostGIS, and RPC backend integration |
| `geolocator` | `^13.0.2` | Device GPS location fetching for spatial doctor search |
| `google_fonts` | `^7.0.1` | Typography (Inter & Plus Jakarta Sans fonts) |
| `sentry_flutter` | `^8.9.0` | Crash reporting and error tracking |
| `logging` | `^1.3.0` | Structured application logging singleton |
| `google_sign_in` | `^6.2.1` | OAuth Google Authentication |
| `shared_preferences` | `^2.2.2` | Local storage (caching anonymous user ID for data merging) |
| `cached_network_image` | `^3.4.1` | Doctor avatar network image caching |
| `shimmer` | `^3.0.0` | Shimmer loading skeleton UI effects |
| `intl` | `^0.20.0` | Date and time formatting |

---

## 3. Database Implementation (Supabase & PostGIS)

### Client Initialization
Supabase is initialized once during app startup in `lib/main.dart` via compile-time variables passed through `--dart-define`:
```dart
await Supabase.initialize(
  url: Env.supabaseUrl,
  publishableKey: Env.supabasePublishableKey,
);
```
All widgets and notifiers access Supabase exclusively through `supabaseClientProvider` (`lib/providers/supabase_client_provider.dart`).

### Database Schema Summary (`sql/schema.sql` & `supabase/schema.sql`)
- **`public.doctors`**: Stores doctor info, ratings, specialization, credentials, JSONB expertise metadata, and PostGIS `geography(Point, 4326)` location with GIST spatial index.
- **`public.availability_slots`**: Stores available appointment slots (`doctor_id`, `start_time`, `is_booked`).
- **`public.favorites`**: Junction table for user favorited doctors (`user_id`, `doctor_id`).
- **`public.appointments`**: Stores scheduled appointments (`user_id`, `doctor_id`, `scheduled_for`, `status`).
- **`public.profiles`**: Tracks user profile status (`is_anonymous`, `anonymous_token`).

### PostGIS & Remote Procedure Calls (RPC)
1. **`nearby_doctors(lat, lng, radius_km)`**: PostGIS spatial search calculating `ST_Distance` and filtering via `ST_DWithin` on doctor locations.
2. **`merge_anonymous_data(p_old_anon_id, p_new_user_id)`**: Merges guest favorites and appointments into a newly authenticated user account.
3. **`handle_new_user()`**: Database trigger auto-creating a `profiles` row upon `auth.users` insertion.

---

## 4. Authentication Implementation

### Overview
Auth is managed reactively via `authProvider` (`lib/providers/auth_provider.dart`), supporting three sign-in flows:

1. **Magic Link / OTP Sign-In (`signInWithOtp`)**: Sends OTP to user's email via Supabase Auth.
2. **Google OAuth (`signInWithGoogle`)**: Uses `google_sign_in` to retrieve ID tokens and authenticates with `Supabase.auth.signInWithIdToken()`.
3. **Anonymous Guest Mode (`signInAnonymously`)**: Allows users to explore and interact as a guest.

### Guest-to-User Local Persistence & Data Merging
- When signing in anonymously, the user's generated `userId` is saved locally in `SharedPreferences` under `cached_anonymous_user_id`.
- When the user subsequently signs in with Google or Email, `AuthNotifier` detects the user ID change in `_subscription` and automatically calls `_attemptMergeIfNeeded()`.
- `_attemptMergeIfNeeded()` triggers `AuthRepository.mergeAnonymousData()`, executing the Supabase RPC `merge_anonymous_data` to reassign guest appointments and favorites to the new permanent user account.

---

## 5. Routing & State Management

### Declarative Routing (`lib/utils/app_router.dart`)
Uses `go_router` with `StatefulShellRoute.indexedStack` for bottom tab navigation:
- **Tab 1 (`/`)**: Home Screen (`HomeScreen`)
- **Tab 2 (`/favorites`)**: Favorites Screen (`FavoritesScreen`)
- **Tab 3 (`/appointments`)**: Appointments Screen (`AppointmentsScreen`)

Parent routes:
- `/onboarding`: Initial onboarding flow
- `/login`: Authentication screen (`AuthScreen`)
- `/doctor/:id`: Doctor detailed profile (`DoctorDetailsScreen`)
- `/booking/:doctorId`: Booking screen (`BookingScreen`)

### Route Guarding
`GoRouter.redirect` watches `authProvider`. If unauthenticated, public access is restricted to `/onboarding` and `/login`.

---

## 6. Screen & Feature Summary

1. **Onboarding Screen (`OnboardingScreen`)**: App intro and navigation trigger to `/login`.
2. **Authentication Screen (`AuthScreen`)**: Email OTP magic link, Google sign-in button, and guest access button.
3. **Home Screen (`HomeScreen`)**:
   - Location header (GPS coordinates & location status via `locationProvider`)
   - Specialty horizontal filter carousel
   - Top-rated doctor list & Nearby doctor spatial list
   - Shimmer skeleton loaders during data fetch
4. **Doctor Details Screen (`DoctorDetailsScreen`)**: Displays full bio, credentials, sub-specialty, contact info, ratings, and favorite toggle.
5. **Booking Screen (`BookingScreen`)**: Time-slot picker fetching live availability slots via `AvailabilityRepository` and appointment booking confirmation.
6. **Favorites Screen (`FavoritesScreen`)**: Saved doctors list synchronized with Supabase.
7. **Appointments Screen (`AppointmentsScreen`)**: List of upcoming and past user appointments with cancellation capability.

---

## 7. Compliance & Areas for Improvement

- **Issue Trackers / TODOs**:
  - `lib/providers/auth_provider.dart:138`: `// TODO: Show loading state during merge (e.g., "Finalizing your account...")`
- **Rule Alignment (`AGENTS.md`)**:
  - Direct Supabase calls are kept strictly inside the repository layer.
  - Logging is routed via `LoggerService` (no `print()` usage).
  - Immumutable models with `copyWith`.
