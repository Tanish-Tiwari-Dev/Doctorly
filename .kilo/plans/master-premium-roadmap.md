# Doctorly Premium Gap Analysis
**Audit Date:** 2026-08-30  
**Auditor:** Kilo (Senior Product Architect / Lead Flutter Engineer)  
**Scope:** Full codebase audit for production-readiness vs. premium telehealth standards (Practo, Zocdoc, Teladoc, 1mg)  
**Constraint:** Read-only audit — no code changes made.

---

## Executive Summary

Doctorly is a **Phase 5/6 MVP** with solid architectural foundations (Riverpod AsyncNotifier, repository layer, PostGIS, anonymous auth with merge). However, it is **not production-ready** for a premium telehealth launch. The gap between current state and a Practo/Zocdoc-class app is significant across all seven audit dimensions.

**Top-line blockers:**
- Only 6 mock doctors; no realistic data scale.
- No double-booking protection at the DB level.
- No real error reporting (Sentry/Crashlytics).
- Anonymous auth is wired but has no "Continue as Guest" entry point.
- No reviews/ratings system.
- No push notifications or deep linking.
- Multiple architecture violations per `AGENTS.md`.

---

## 1. Core Feature Gaps (Compared to Premium Apps)

### 1.1 Authentication
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.1.1 | **No "Continue as Guest" / anonymous sign-in entry point.** `signInAnonymously()` exists in `AuthNotifier` (`lib/providers/auth_provider.dart:58`) but is never called from any screen. Users cannot start as a guest. | `lib/screens/auth_screen.dart:1-433` | Missing Feature |
| 1.1.2 | **No email/password sign-up.** Only OTP magic link (`signInWithOtp`), Google, and Apple are implemented. Premium apps support traditional email/password registration with strength meter. | `lib/providers/auth_provider.dart:144-157` | Missing Feature |
| 1.1.3 | **No password reset / forgot-password flow.** Users who lose access to their email magic link have no recovery path. | `lib/screens/auth_screen.dart:1-433` | Missing Feature |
| 1.1.4 | **No phone / OTP SMS authentication.** Mobile-first markets expect SMS OTP as a primary sign-in method. | — | Missing Feature |
| 1.1.5 | **Auth screen uses `plusJakartaSans` inline** instead of the app theme's `TextTheme`, violating the project's own `AGENTS.md` convention. | `lib/screens/auth_screen.dart:89,172,196,235,261,284,307,355,367,374,423` | Architecture/UX Gap |
| 1.1.6 | **`Supabase.instance.client` called directly** in `auth_provider.dart` on lines 31, 59, 85, 93, 119, 146, 162 instead of reading `supabaseClientProvider`. This violates `AGENTS.md`: "All Supabase access goes through supabaseClientProvider." | `lib/providers/auth_provider.dart:31,59,85,93,119,146,162` | Architecture/UX Gap |

### 1.2 Doctor Profiles
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.2.1 | **Doctor model is skeletal.** No fields for `education`, `licenseNumber`, `languagesSpoken`, `hospitalAffiliations`, `yearsOfExperience`, `consultationFee`, `bio`, `acceptingNewPatients`. The `Doctor` model only has 7 fields (`lib/models/doctor.dart:5-15`). | `lib/models/doctor.dart:5-15` | Missing Feature |
| 1.2.2 | **Doctor detail screen shows a hardcoded generic "About" blurb** (`lib/screens/doctor_details_screen.dart:218`: "Experienced {specialty} dedicated to providing top-notch medical care.") instead of real doctor-specific biography. | `lib/screens/doctor_details_screen.dart:218` | Bug |
| 1.2.3 | **No "Reviews" section** on doctor profiles. Premium apps display aggregated ratings, review count, and individual user reviews. | `lib/screens/doctor_details_screen.dart:1-281` | Missing Feature |
| 1.2.4 | **No consultation fee displayed.** Users cannot see pricing before booking. | `lib/models/doctor.dart`, `lib/widgets/doctor_card.dart`, `lib/screens/doctor_details_screen.dart` | Missing Feature |

### 1.3 Booking System
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.3.1 | **Time slots are hardcoded, not fetched from the doctor's actual availability.** `booking_screen.dart:15` defines `_timeSlots = ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']` statically. Real apps query the doctor's schedule. | `lib/screens/booking_screen.dart:15` | Missing Feature |
| 1.3.2 | **No double-booking prevention at the DB level.** The `appointments` table has no unique constraint on `(doctor_id, scheduled_for)`. Two users can book the same slot simultaneously. | `supabase/schema.sql:32-39` | Bug |
| 1.3.3 | **No cancellation UI.** `AppointmentsNotifier.cancel()` exists (`lib/providers/appointments_provider.dart:43-62`) but there is no "Cancel" button in the appointments list. Users cannot cancel from the app. | `lib/screens/appointments_screen.dart:76-93` | Missing Feature |
| 1.3.4 | **No confirmation flow after booking.** After `_confirmBooking` succeeds, it immediately navigates to `/appointments` with a generic SnackBar. Premium apps show a confirmation screen with calendar invite / ICS download option. | `lib/screens/booking_screen.dart:31-73` | Missing Feature |
| 1.3.5 | **Booking error is swallowed silently.** `_confirmBooking` catches `_` and shows "Could not book. Try again." without logging the underlying error. | `lib/screens/booking_screen.dart:61-72` | Bug |
| 1.3.6 | **No minimum lead time or buffer.** Users can book appointments in the past or for 1 minute from now if the time slot matches. | `lib/providers/booking_provider.dart:22` | Bug |

### 1.4 User Profiles
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.4.1 | **No "My Profile" or "Settings" screen.** There is no place to view/edit name, phone, email, or notification preferences. | — | Missing Feature |
| 1.4.2 | **No "Past Appointments" / appointment history view.** The appointments screen lists all appointments but has no tab or filter for past vs. upcoming. | `lib/screens/appointments_screen.dart:1-131` | Missing Feature |
| 1.4.3 | **No notification management.** No in-app settings for push notification preferences (appointment reminders, promotions, etc.). | — | Missing Feature |
| 1.4.4 | **No logout button in any persistent UI.** `signOut()` exists (`lib/providers/auth_provider.dart:159-170`) but there is no settings screen to trigger it. | — | Missing Feature |

### 1.5 Search & Filters
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.5.1 | **No fee-based filtering.** Users cannot filter doctors by consultation cost. | `lib/providers/doctor_provider.dart:82-110` | Missing Feature |
| 1.5.2 | **No availability date filtering.** Users cannot search "available tomorrow" or "available this week." | `lib/providers/doctor_provider.dart:82-110` | Missing Feature |
| 1.5.3 | **No distance-based sorting/filtering controls.** The home screen has a "Near Me" button but no slider or radius selector. | `lib/screens/home_screen.dart:29-108` | Missing Feature |
| 1.5.4 | **Search is name/specialty only.** No autocomplete, no typo tolerance, no search history. | `lib/providers/doctor_provider.dart:60-80` | Missing Feature |

### 1.6 Reviews & Ratings
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.6.1 | **No reviews/ratings system at all.** Users cannot leave reviews, and doctor detail screens do not show review breakdowns or written reviews. | — | Missing Feature |
| 1.6.2 | **Rating is a single decimal field** in the DB (`supabase/schema.sql:16`: `rating numeric(2,1)`). There is no `reviews` table, no `review_count`, and no ability to submit a review post-appointment. | `supabase/schema.sql:10-20` | Missing Feature |

### 1.7 Real Data
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 1.7.1 | **Seed data has only 6 doctors** (`supabase/seed.sql:5-34`). Premium apps require 50+ realistic doctors with varied specialties, fees, locations, and availability for meaningful search/filter UX. | `supabase/seed.sql:5-34` | Missing Feature |
| 1.7.2 | **All doctors are concentrated in Bangalore** (`supabase/seed.sql:1-35`). No geographic diversity for testing. | `supabase/seed.sql:1-35` | Missing Feature |
| 1.7.3 | **`availability` is a free-text string** (`supabase/schema.sql:18`: `availability text`). This is not queryable or structured. It should be a JSONB or a separate `availability_slots` table. | `supabase/schema.sql:18` | Architecture/UX Gap |

---

## 2. UI/UX & Polish (Mobbin/Spotify Standard)

### 2.1 Loading States
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.1.1 | **No skeleton/shimmer loaders.** Every loading state uses `CircularProgressIndicator` centered on screen. Premium apps use skeleton cards that mimic the final layout. | `lib/screens/home_screen.dart:121-130`, `lib/screens/appointments_screen.dart:23`, `lib/screens/favorites_screen.dart:22`, `lib/screens/doctor_details_screen.dart:22` | Architecture/UX Gap |
| 2.1.2 | **Doctor image placeholder is a spinner, not a shimmer.** `CachedNetworkImage` shows a spinner while loading (`lib/screens/doctor_details_screen.dart:91-103`), which breaks the visual continuity of the hero image. | `lib/screens/doctor_details_screen.dart:91-103` | Architecture/UX Gap |

### 2.2 Empty States
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.2.1 | **Empty states are mostly actionable** (e.g., "No favorites yet. Tap the heart on any doctor to save them." — `lib/screens/favorites_screen.dart:33-37`). The `EmptyState` widget supports `onRetry`. However, the empty state for "No doctors found" (`lib/screens/home_screen.dart:282-287`) does not include a CTA to clear filters. | `lib/screens/home_screen.dart:282-287` | Architecture/UX Gap |
| 2.2.2 | **No empty state for "No nearby doctors" with a radius adjuster.** The SnackBar at `lib/screens/home_screen.dart:80-88` is transient; it should be a persistent empty state with an "Increase radius" action. | `lib/screens/home_screen.dart:80-88` | Architecture/UX Gap |

### 2.3 Error States
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.3.1 | **Error states are generic.** "Could not load doctors" / "Could not load appointments" do not explain *why* (network down? server error? empty DB?). | `lib/screens/home_screen.dart:139`, `lib/screens/appointments_screen.dart:26` | Architecture/UX Gap |
| 2.3.2 | **Booking error swallows the exception.** `_confirmBooking` catches `_` and shows a generic message without logging or surfacing the real error. | `lib/screens/booking_screen.dart:61-72` | Bug |
| 2.3.3 | **Favorites error state shows raw exception string** (`lib/screens/favorites_screen.dart:26`: `subtitle: e.toString()`). This leaks internal details to users. | `lib/screens/favorites_screen.dart:26` | Bug |

### 2.4 Animations
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.4.1 | **Hero transitions exist** for doctor images (`lib/widgets/doctor_card.dart:49-58` → `lib/screens/doctor_details_screen.dart:84-115`). Good. | — | — |
| 2.4.2 | **No list-item entrance animations.** Doctor cards appear instantly without staggered fade/slide-in. | `lib/screens/home_screen.dart:290-327` | Architecture/UX Gap |
| 2.4.3 | **No shared-element transitions for booking confirmation.** The transition from doctor details → booking → confirmation is a hard push/pop. | — | Architecture/UX Gap |

### 2.5 Accessibility
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.5.1 | **No `Semantics` labels on icon-only buttons.** The favorite heart button (`lib/widgets/doctor_card.dart:145-157`), near-me button (`lib/screens/home_screen.dart:179-190`), and back arrow (`lib/screens/doctor_details_screen.dart:57-66`) lack `semanticLabel`. | `lib/widgets/doctor_card.dart:145`, `lib/screens/home_screen.dart:179`, `lib/screens/doctor_details_screen.dart:57` | Architecture/UX Gap |
| 2.5.2 | **Tap target sizes are mostly ≥48×48** (e.g., `SizedBox(width: 48, height: 48)` at `lib/widgets/doctor_card.dart:142-144`), but `FilterChip` and `ChoiceChip` tap targets may be smaller on some devices. | `lib/screens/booking_screen.dart:247-274` | Architecture/UX Gap |
| 2.5.3 | **No `Semantics` for dynamic content** (loading, error, empty states). Screen readers announce nothing during data fetches. | `lib/widgets/empty_state.dart`, `lib/widgets/error_boundary.dart` | Architecture/UX Gap |

### 2.6 Responsiveness
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 2.6.1 | **Basic responsiveness exists.** `BottomNavScaffold` switches to `NavigationRail` at `constraints.maxWidth >= 600` (`lib/widgets/bottom_nav_scaffold.dart:33`). `HomeScreen` switches from `SliverList` to `SliverGrid` at 600px (`lib/screens/home_screen.dart:292`). | `lib/widgets/bottom_nav_scaffold.dart:33`, `lib/screens/home_screen.dart:292` | — |
| 2.6.2 | **No tablet-specific layout for doctor details.** The detail screen uses a single-column `CustomScrollView` even on wide screens. Premium apps show a split layout (image left, details right) on tablet/desktop. | `lib/screens/doctor_details_screen.dart:49-252` | Architecture/UX Gap |
| 2.6.3 | **Web target is untested.** `kIsWeb` checks exist (`lib/screens/auth_screen.dart:118`) but there is no web-specific layout adaptation (e.g., constrained max-width container, hover states). | — | Architecture/UX Gap |

---

## 3. Location & Maps (PostGIS)

### 3.1 Permission Flow
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 3.1.1 | **`LocationPermission.deniedForever` is silently ignored.** `location_service.dart:18-20` returns `false` without prompting the user to open app settings. Premium apps show a dialog: "Location permission denied permanently. Open Settings?" | `lib/utils/location_service.dart:18-20` | Architecture/UX Gap |
| 3.1.2 | **No "Open Settings" deep-link.** When location is denied forever, there is no mechanism to launch `Geolocator.openLocationSettings()`. | `lib/utils/location_service.dart:18-20` | Missing Feature |

### 3.2 Nearby Doctors RPC
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 3.2.1 | **`nearby_doctors` RPC is called directly in the screen** (`lib/screens/home_screen.dart:63-68`) instead of through `DoctorsRepository.fetchNearby()`. The repository method exists (`lib/repositories/doctors_repository.dart:47-68`) but is unused. This duplicates parsing logic (`_doctorFromRpc` at `lib/screens/home_screen.dart:111`). | `lib/screens/home_screen.dart:63-68,111`, `lib/repositories/doctors_repository.dart:47-68` | Architecture/UX Gap |
| 3.2.2 | **The RPC response does not include `address`**, but the DB schema has it (`supabase/schema.sql:15`). The RPC return type omits `address` (`supabase/schema.sql:92-100`), so even if the DB has addresses, they are not returned to the client. | `supabase/schema.sql:92-100` | Bug |

### 3.3 Distance Display
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 3.3.1 | **Distance is shown in km** (`lib/widgets/doctor_card.dart:136`: `'${doctor.distanceKm.toStringAsFixed(1)} km'`) but the RPC returns `distance_m` in meters. The `Doctor.fromJson` correctly converts to km (`lib/models/doctor.dart:28-33`), but if `distance_m` is null (e.g., from `fetchAll`), `distanceKm` defaults to `0.0` and displays as "0.0 km". | `lib/models/doctor.dart:28-33`, `lib/widgets/doctor_card.dart:136` | Bug |
| 3.3.2 | **No distance unit adaptation.** International users expect miles. The app hardcodes "km". | `lib/widgets/doctor_card.dart:136` | Architecture/UX Gap |

### 3.4 Map View
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 3.4.1 | **No map view.** The app is list-only. Premium apps have a map/list toggle. There is no `google_maps_flutter` or `mapbox_gl` dependency in `pubspec.yaml`. | `pubspec.yaml:9-26` | Missing Feature |

---

## 4. Backend & Database Integrity

### 4.1 Schema
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 4.1.1 | **`doctors` table is denormalized.** There is no `clinics` table, no `educations` table, no `languages` table. All data is flat in `doctors`. This prevents rich doctor profiles. | `supabase/schema.sql:10-20` | Architecture/UX Gap |
| 4.1.2 | **`availability` is a free-text field** (`supabase/schema.sql:18`). Cannot be queried for "available tomorrow" or "available between 2-4 PM." | `supabase/schema.sql:18` | Architecture/UX Gap |
| 4.1.3 | **No `consultation_fee` column.** Cannot sort/filter by price. | `supabase/schema.sql:10-20` | Missing Feature |
| 4.1.4 | **Duplicate `profiles` table creation.** `supabase/migrations/20231025000000_profiles_and_merge.sql:5-10` and `supabase/schema.sql:128-133` both create the same `profiles` table. If run sequentially without `IF NOT EXISTS`, the second run errors. | `supabase/schema.sql:128-133`, `supabase/migrations/20231025000000_profiles_and_merge.sql:5-10` | Architecture/UX Gap |
| 4.1.5 | **Duplicate `merge_anonymous_data` RPC** and `handle_new_user` trigger exist in both `schema.sql` and the migration file. Same drift risk. | `supabase/schema.sql:150-211`, `supabase/migrations/20231025000000_profiles_and_merge.sql:24-87` | Architecture/UX Gap |

### 4.2 RLS
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 4.2.1 | **RLS policies are correctly scoped.** `favorites` and `appointments` restrict reads/updates to `auth.uid() = user_id`. `doctors` allows public read (correct for a directory app). | `supabase/schema.sql:45-82` | — |
| 4.2.2 | **`merge_anonymous_data` is `security definer`** (`supabase/schema.sql:160`). This is necessary for anon→auth data transfer, but the function should validate that `p_old_anon_id` is actually anonymous (currently trusts the caller). | `supabase/schema.sql:150-188` | Bug |

### 4.3 Constraints
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 4.3.1 | **No unique constraint preventing double-booking.** Two concurrent requests can insert `(doctor_id=abc, scheduled_for=2024-01-01T10:00:00Z)` twice. | `supabase/schema.sql:32-39` | Bug |
| 4.3.2 | **No check that `scheduled_for` is in the future.** A client could book an appointment in the past. | `supabase/schema.sql:32-39` | Bug |
| 4.3.3 | **`appointments` `status` has a check constraint** (`supabase/schema.sql:37`: `check (status in ('pending','confirmed','cancelled'))`). Good. | `supabase/schema.sql:37` | — |

### 4.4 Realtime
| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 4.4.1 | **No Supabase Realtime subscriptions.** The app polls via `AsyncNotifier.build()` and `ref.invalidateSelf()`. Premium apps use Realtime to push appointment confirmations ("Doctor confirmed your appointment") without manual refresh. | `lib/providers/appointments_provider.dart:10-19` | Missing Feature |
| 4.4.2 | **Favorites are not realtime either.** If a user favorites a doctor on another device, the change is not reflected until a manual refresh. | `lib/providers/favorites_provider.dart:9-20` | Missing Feature |

---

## 5. Edge Cases & Error Handling

| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 5.1 | **Silent error swallowing in booking.** `booking_screen.dart:61` catches `_` and shows a generic SnackBar. If the network drops mid-booking, the user sees "Could not book. Try again." with no retry logic or queue. | `lib/screens/booking_screen.dart:61-72` | Bug |
| 5.2 | **No offline mode handling.** If the device is offline, every Supabase call fails with a raw error. There is no `connectivity_plus` check, no optimistic UI rollback guidance, and no "You are offline" banner. | — | Missing Feature |
| 5.3 | **Doctor deletion leaves orphaned appointments.** If a doctor is deleted (cascade), the user's appointment shows "Unknown doctor" (`lib/screens/appointments_screen.dart:49-50`). There is no notification or cleanup. | `lib/screens/appointments_screen.dart:49-50` | Bug |
| 5.4 | **Timezone mismatch risk.** `AppointmentsRepository.create` converts to UTC (`lib/repositories/appointments_repository.dart:42`), but the UI displays `toLocal()` (`lib/screens/appointments_screen.dart:51`). If the clinic is in a different timezone than the user, the displayed time is wrong. There is no timezone handling. | `lib/repositories/appointments_repository.dart:42`, `lib/screens/appointments_screen.dart:51` | Bug |
| 5.5 | **`RepositoryExceptionKind` is always `unknown`.** Every repository catches `e` and throws `RepositoryException(RepositoryExceptionKind.unknown, e.toString())` (`lib/repositories/doctors_repository.dart:23-27`, `lib/repositories/appointments_repository.dart:24-28`, etc.). This makes it impossible to distinguish network errors from not-found or auth errors. | `lib/repositories/doctors_repository.dart:23-27`, `lib/repositories/appointments_repository.dart:24-28`, `lib/repositories/favorites_repository.dart:23-27` | Architecture/UX Gap |
| 5.6 | **`location_service.dart` returns `null` on errors without logging.** `getCurrentPosition` catches `_` and returns `null` (`lib/utils/location_service.dart:34-36`), making debugging impossible. | `lib/utils/location_service.dart:34-36` | Bug |
| 5.7 | **Auth merge failure is silently ignored.** `_attemptMergeIfNeeded` catches errors and logs them but does not inform the user that their anonymous data was not transferred. | `lib/providers/auth_provider.dart:188-191` | Bug |

---

## 6. Security & Compliance

| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 6.1 | **No PHI (Protected Health Information) safeguards.** The app handles appointment scheduling with doctor names, but there is no audit log, no data-retention policy, and no encryption-at-rest enforcement. For a production telehealth app, HIPAA/GDPR compliance requires: audit logging, BAA with Supabase, encrypted storage for sensitive fields, and user consent flows. | — | Missing Feature |
| 6.2 | **No crash reporting / error reporter.** `ErrorReporter` is `NoopErrorReporter` (`lib/services/error_reporter.dart`). In production, crashes are invisible. Sentry, Crashlytics, or Sentry must be integrated. | `lib/services/error_reporter.dart`, `lib/providers/error_reporter_provider.dart` | Missing Feature |
| 6.3 | **Logger uses `debugPrint`** (`lib/services/logger.dart:27-30`). In release mode, `debugPrint` may batch or drop output. More importantly, if log statements ever include PHI (e.g., user names, appointment details), they could end up in crash reports or debug dumps. | `lib/services/logger.dart:27-30` | Bug |
| 6.4 | **No hardcoded secrets found.** `.env` is gitignored (implied by `flutter_dotenv` usage). `pubspec.yaml` has no API keys. | `pubspec.yaml` | — |
| 6.5 | **Anonymous auth creates public `profiles` rows.** The `handle_new_user` trigger sets `is_anonymous = true` for anon users (`supabase/schema.sql:194-211`). These rows are readable by `anon` role via the "profiles read own" policy only if `auth.uid() = user_id` — but anon users have no `auth.uid()` until they sign in. This may cause `profiles` rows to be unreadable by their creator. | `supabase/schema.sql:139-146` | Bug |

---

## 7. Production Operations & Polish

| # | Finding | File:Line | Type |
|---|---------|-----------|------|
| 7.1 | **No push notifications.** No `firebase_messaging` or similar in `pubspec.yaml`. Premium apps send appointment reminders (1 hour before), booking confirmations, and promotional alerts. | `pubspec.yaml` | Missing Feature |
| 7.2 | **No deep linking.** No `uni_links` or `app_links` configuration. Users cannot share a doctor's profile via WhatsApp or open the app from a notification link. | `pubspec.yaml`, `lib/utils/app_router.dart` | Missing Feature |
| 7.3 | **No app icon / splash screen configuration.** `pubspec.yaml` has no `flutter_launcher_icons` or `flutter_native_splash` dev dependency. Native assets are unconfigured. | `pubspec.yaml:28-35` | Missing Feature |
| 7.4 | **No internationalization (i18n).** The app is hardcoded to English. `intl` is in `pubspec.yaml` but only used for date formatting (`DateFormat('EEE, MMM d')` at `lib/screens/appointments_screen.dart:39`). No `l10n/` arb files, no `AppLocalizations`. | `pubspec.yaml:17`, `lib/screens/appointments_screen.dart:39` | Missing Feature |
| 7.5 | **Duplicate repository: `doctor_repository.dart`.** `lib/repositories/doctor_repository.dart` (singular) is a legacy file with no provider. `lib/repositories/doctors_repository.dart` (plural) is the active one. `doctor_provider.dart:11-13` redefines `doctorRepositoryProvider` instead of importing from `repositories/doctors_repository.dart`. | `lib/repositories/doctor_repository.dart:1-40`, `lib/providers/doctor_provider.dart:11-13` | Architecture/UX Gap |
| 7.6 | **`location_service.dart` is in `lib/utils/`** instead of `lib/services/`. `AGENTS.md` specifies "services under lib/services/". | `lib/utils/location_service.dart:1-38`, `lib/providers/location_provider.dart:1-4` | Architecture/UX Gap |
| 7.7 | **No CI/CD pipeline visible.** No `.github/workflows/`, no Fastlane, no automated tests on PR. | — | Missing Feature |
| 7.8 | **No feature flags or remote config.** Cannot roll out features gradually or toggle experimental features. | — | Missing Feature |

---

## Prioritized Remediation Table

| Priority | Issue | Phase to tackle | Effort (S/M/L) |
|----------|-------|-----------------|----------------|
| P0 | **No double-booking DB constraint.** Two users can book the same slot. | Phase A — Backend Hardening | S |
| P0 | **Booking error swallowed silently** (`catch (_)` without logging). | Phase A — Backend Hardening | S |
| P0 | **No error reporter** (NoopErrorReporter). Crashes are invisible in production. | Phase A — Backend Hardening | S |
| P0 | **Anonymous auth has no UI entry point.** Users cannot start as guests. | Phase A — Auth UX | M |
| P0 | **Only 6 mock doctors.** No realistic data scale for search/filter testing. | Phase A — Data Seeding | M |
| P0 | **No push notifications.** Appointment reminders are a core premium feature. | Phase B — Engagement | L |
| P1 | **No DB-level `scheduled_for` future check.** Users can book in the past. | Phase A — Backend Hardening | S |
| P1 | **`nearby_doctors` RPC omits `address` column.** Doctor address lost on nearby search. | Phase A — Backend Hardening | S |
| P1 | **`RepositoryExceptionKind` always `unknown`.** Cannot distinguish error types for UX. | Phase A — Backend Hardening | M |
| P1 | **No "Cancel Appointment" UI.** Cancel method exists but is unreachable. | Phase A — Auth UX | S |
| P1 | **Doctor profile model is skeletal.** No education, languages, fees, experience. | Phase B — Profile Enrichment | L |
| P1 | **No reviews/ratings system.** Core social proof missing. | Phase B — Profile Enrichment | L |
| P1 | **`Supabase.instance.client` used directly in `auth_provider.dart`.** Violates architecture rule. | Phase A — Backend Hardening | S |
| P1 | **Duplicate repository `doctor_repository.dart`.** Dead code / confusion risk. | Phase A — Backend Hardening | S |
| P2 | **`deniedForever` location permission not handled gracefully.** No "Open Settings" prompt. | Phase B — Location UX | S |
| P2 | **No skeleton/shimmer loaders.** Loading states are bare spinners. | Phase B — UI Polish | M |
| P2 | **No i18n.** Hardcoded English only. | Phase B — i18n | L |
| P2 | **No deep linking / app sharing.** Cannot share doctor profiles. | Phase B — Engagement | M |
| P2 | **No tablet/web layout for doctor details.** Single-column only. | Phase B — UI Polish | M |
| P2 | **`merge_anonymous_data` does not validate old ID is anonymous.** Security definer trusts caller. | Phase A — Backend Hardening | S |
| P3 | **No password-based auth / forgot-password flow.** | Phase C — Auth Expansion | M |
| P3 | **No map view toggle.** List-only discovery. | Phase C — Map Integration | L |
| P3 | **No offline mode / connectivity check.** | Phase C — Resilience | M |
| P3 | **No user profile/settings screen.** Logout, notification prefs, edit profile. | Phase C — Profile UX | M |
| P3 | **No app icon / splash screen configured.** | Phase C — Production Polish | S |
| P3 | **`location_service.dart` in `utils/` instead of `services/`.** | Phase C — Production Polish | S |
| P3 | **Auth screen uses `plusJakartaSans` inline** instead of theme `TextTheme`. | Phase C — Production Polish | S |

---

## Recommended Phase Roadmap

**Phase A — Backend Hardening (Weeks 1-2)**
- Add unique constraint `UNIQUE(doctor_id, scheduled_for)` on `appointments`.
- Add check constraint `scheduled_for > now()`.
- Fix `nearby_doctors` RPC to return `address`.
- Replace `RepositoryExceptionKind.unknown` with typed errors (network, notFound, unauthorized).
- Remove `Supabase.instance.client` direct calls from `auth_provider.dart`.
- Delete dead `doctor_repository.dart`.
- Add Sentry/Crashlytics integration.
- Add logging for all caught errors in repositories and screens.

**Phase B — Core UX (Weeks 3-5)**
- Add "Continue as Guest" entry point to `auth_screen.dart`.
- Add "Cancel Appointment" button to appointments list.
- Add skeleton loaders to all list screens.
- Enrich `Doctor` model: add `fee`, `experienceYears`, `education`, `languages`, `bio`.
- Seed 50+ realistic doctors across multiple cities.
- Add `clinics` and `educations` tables (normalize schema).
- Add `consultation_fee` to doctors; add fee filter to home screen.
- Add `availability_slots` JSONB column or separate table.

**Phase C — Premium Features (Weeks 6-8)**
- Implement reviews/ratings system (new `reviews` table + UI).
- Add push notifications (FCM for Android, APNs for iOS).
- Add deep linking (`app_links`) for doctor profile sharing.
- Add i18n (`l10n/arb` files + `AppLocalizations`).
- Add map view (`google_maps_flutter`) with doctor markers.
- Add user profile/settings screen.
- Add offline detection banner and retry queue.
- Configure launcher icons and splash screens.

**Phase D — Production Readiness (Weeks 9-10)**
- Add CI/CD (GitHub Actions + Fastlane).
- Add integration tests for booking flow.
- Add accessibility audit (semantic labels, tap targets, screen reader).
- Add tablet/desktop responsive layouts.
- Add PHI audit, BAA, and compliance documentation.
- Performance profiling (scroll jank, image caching, bundle size).