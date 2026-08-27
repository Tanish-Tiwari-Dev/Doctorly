# Doctorly — Phase 5: App Expansion (UI/UX & Booking)

## 1. Goal & Non-Goals

**Goal**
Expand Doctorly from a 3-screen MVP into a tabbed app with Favorites, Appointments, and a full booking flow, backed by **Supabase (PostgreSQL + PostGIS)** for persistence and geospatial queries. Keep the Flutter codebase for Android + Web.

**In scope (Phase 5)**
- 3-tab bottom navigation: Home / Favorites / Appointments
- Favorites system (toggle, list view, persisted to Supabase)
- Booking flow (date + time selection, persisted to Supabase)
- FilterChips for specialties on Home
- Supabase project schema, PostGIS geospatial column, RLS policies
- Seed SQL with the 6 existing mock doctors
- Async providers throughout (replaces synchronous `Provider` chain)

**Out of scope (deferred)**
- Real authentication (use Supabase anon key + a hardcoded `user_id` UUID for MVP)
- Payments, telemedicine, push notifications
- Doctor reviews / ratings submission
- iOS target
- Production secrets management (use a `lib/utils/env.dart` reading from `--dart-define` for now)

**Assumptions**
- User has created a free Supabase project and will provide the URL and `anon` key via `--dart-define`.
- Schema is fresh; no existing production data.
- The 6 existing mock doctors are the seed dataset.

---

## 2. Dependencies to Add / Change (`pubspec.yaml`)

| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | `^2.5.0` | Supabase client (auth + DB + realtime) |
| `flutter_riverpod` | already present | State management |
| `go_router` | already present | Routing + ShellRoute |
| `geolocator` | already present | "Near Me" — replace mock distance with PostGIS `ST_Distance` |
| `intl` | `^0.20.0` | Date / time formatting in booking flow |
| `flutter_dotenv` | optional, not required | `.env` file support (skip; use `--dart-define`) |

**Remove:** `lib/utils/mock_doctors.dart` (moved to `supabase/seed.sql`).

---

## 3. New Folder Structure

```
lib/
├── main.dart                          # initialize Supabase, ProviderScope, MaterialApp.router
├── env.dart                           # reads SUPABASE_URL / SUPABASE_ANON_KEY from --dart-define
├── models/
│   ├── doctor.dart                    # (existing) — add @JsonSerializable if not present
│   ├── appointment.dart               # NEW
│   └── specialty.dart                 # NEW — enum: cardiology, dermatology, ...
├── screens/
│   ├── home_screen.dart               # (existing) — add FilterChips
│   ├── doctor_details_screen.dart     # (existing) — "Book" navigates to /booking/:id
│   ├── booking_screen.dart            # NEW
│   ├── favorites_screen.dart          # NEW
│   └── appointments_screen.dart       # NEW
├── widgets/
│   ├── doctor_card.dart               # (existing) — add favorite toggle action
│   ├── specialty_chip.dart            # NEW
│   ├── empty_state.dart               # (existing)
│   └── bottom_nav_scaffold.dart       # NEW — wraps tab content with BottomNavigationBar
├── providers/
│   ├── doctor_provider.dart           # REFACTOR — replace with AsyncNotifierProvider
│   ├── location_provider.dart         # (existing)
│   ├── favorites_provider.dart        # NEW — Notifier<Set<int>> backed by Supabase
│   ├── appointments_provider.dart     # NEW — AsyncNotifierProvider<List<Appointment>>
│   └── booking_provider.dart          # NEW — manages form state + submission
└── utils/
    ├── app_router.dart                # REFACTOR — add StatefulShellRoute.indexedStack
    └── location_service.dart          # (existing)

supabase/
├── schema.sql                         # tables, PostGIS extension, RLS, triggers
└── seed.sql                           # inserts the 6 mock doctors
```

---

## 4. Design Decisions (Resolved)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Bottom nav architecture | **StatefulShellRoute.indexedStack** | Free deep-linking (`/favorites` works on Web + Android intent filters), browser history correct, per-tab state preserved (Home keeps scroll position when user visits Appointments). |
| Persistence | **Supabase (PostgreSQL + PostGIS)** | PostGIS `ST_Distance` makes "Near Me" a single SQL query instead of client-side Haversine. PostgreSQL is better than Firebase for geospatial. |
| Mock data fate | **Moved to `supabase/seed.sql`** | Single source of truth, no drift between mock and live schema. |
| Booking screen | **Separate route `/booking/:doctorId`** | Deep-linkable, can be shared / bookmarked, easier to test. |
| Auth | **Deferred — hardcoded `user_id` UUID for MVP** | Add `supabase.auth.signInAnonymously()` call in `main.dart` to get a real session, but no login UI. |

---

## 5. Phased Implementation Steps

### 5.1 — Supabase Setup
**Shippable outcome:** Schema and seed data exist; the app connects to Supabase and the Doctorly table is queryable.

1. Create a free Supabase project at supabase.com. Note the **Project URL** and **anon public** key.
2. Enable the PostGIS extension: Supabase Dashboard → Database → Extensions → search `postgis` → enable.
3. Write `supabase/schema.sql`:
   - `doctors` table: `id uuid primary key default gen_random_uuid()`, `name text not null`, `specialty text not null`, `location geography(Point, 4326) not null` (PostGIS), `address text`, `rating numeric(2,1)`, `image_url text`, `availability text`, `created_at timestamptz default now()`.
   - GIST index on `doctors.location` for fast distance queries.
   - `favorites` table: `user_id uuid references auth.users(id) on delete cascade`, `doctor_id uuid references doctors(id) on delete cascade`, `created_at timestamptz default now()`, `primary key (user_id, doctor_id)`.
   - `appointments` table: `id uuid primary key default gen_random_uuid()`, `user_id uuid references auth.users(id) on delete cascade`, `doctor_id uuid references doctors(id)`, `scheduled_for timestamptz not null`, `status text not null check (status in ('pending','confirmed','cancelled'))`, `created_at timestamptz default now()`.
   - RLS policies:
     - `doctors`: `select` allowed for `anon` and `authenticated`.
     - `favorites`: `all` allowed for `auth.uid() = user_id`.
     - `appointments`: `all` allowed for `auth.uid() = user_id`.
4. Write `supabase/seed.sql` with the 6 doctors from the existing mock data, including realistic lat/lng (e.g., Bangalore: 12.9716, 77.5946 ± 0.05°). Use `ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography` for the `location` column.
5. Run `schema.sql` then `seed.sql` against the Supabase DB (Dashboard → SQL Editor).
6. Verify: `select id, name, specialty, ST_AsText(location) from doctors;` returns 6 rows.

### 5.2 — Flutter Side: Connect to Supabase
**Shippable outcome:** App boots, signs in anonymously, and `doctorListProvider` returns 6 doctors from Supabase.

1. Add `supabase_flutter: ^2.5.0` to `pubspec.yaml`, run `flutter pub get`.
2. Create `lib/env.dart` with `class Env { static const url = String.fromEnvironment('SUPABASE_URL'); static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY'); }`.
3. Update `lib/main.dart`:
   - `await Supabase.initialize(url: Env.url, anonKey: Env.anonKey);` before `runApp`.
   - `await supabase.auth.signInAnonymously();` (graceful failure → show error screen with retry).
4. Create `lib/models/doctor.dart` — add a `fromJson(Map<String, dynamic>)` factory and `toJson()` (PostGIS `location` is a geography; ignore in `toJson` since we read coords separately).
5. Refactor `lib/providers/doctor_provider.dart`:
   - Replace `doctorListProvider` (sync `Provider`) with `AsyncNotifierProvider<DoctorsNotifier, List<Doctor>>`.
   - `build()`: `final data = await supabase.from('doctors').select().order('name'); return data.map(Doctor.fromJson).toList();`
   - Keep `doctorByIdProvider` as a `Provider.family<Doctor?, int>` derived from the async list.
6. Add `nearbyDoctorsProvider(lat, lng, radiusKm)` using RPC: `supabase.rpc('nearby_doctors', {lat, lng, radius_km: 5})` — see 5.3.
7. Create a Supabase RPC function in `schema.sql`:
   ```sql
   create or replace function nearby_doctors(lat float, lng float, radius_km float default 5)
   returns table (id uuid, name text, specialty text, distance_m float)
   language sql as $$
     select id, name, specialty,
            ST_Distance(location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) as distance_m
     from doctors
     where ST_DWithin(location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radius_km * 1000)
     order by distance_m asc;
   $$;
   ```
8. Verify: launch app → home screen shows 6 doctors from Supabase; `flutter analyze` clean.

### 5.3 — Bottom Navigation Shell
**Shippable outcome:** 3 tabs visible on mobile, sidebar on wide screens, deep-links work.

1. Refactor `lib/utils/app_router.dart`:
   - Top-level `StatefulShellRoute.indexedStack` with 3 branches:
     - `/` → `HomeScreen` (within shell)
     - `/favorites` → `FavoritesScreen` (within shell)
     - `/appointments` → `AppointmentsScreen` (within shell)
   - Out-of-shell routes (rendered above the shell, hiding bottom nav):
     - `/doctor/:id` → `DoctorDetailsScreen`
     - `/booking/:doctorId` → `BookingScreen`
   - Use `shellNavigatorKey` for the shell's nested Navigator.
2. Create `lib/widgets/bottom_nav_scaffold.dart`:
   - Wraps tab content in a `Scaffold` with `BottomNavigationBar` (mobile) or `NavigationRail` (width >= 600, from `LayoutBuilder`).
   - 3 destinations: `Icons.home` / `Icons.favorite_border` / `Icons.calendar_today`.
3. Each tab screen must return **just the body content** (no `Scaffold`); the shell provides the scaffold. Update `home_screen.dart` to remove its outer `Scaffold` and `AppBar` (the shell renders them).
4. Verify: tap each tab → correct content; back/forward on Web updates URL; scroll position preserved when switching tabs; `flutter analyze` clean.

### 5.4 — Favorites System
**Shippable outcome:** User can tap a heart on any doctor card to favorite/unfavorite; Favorites tab shows the saved list.

1. Create `lib/providers/favorites_provider.dart`:
   - `class FavoritesNotifier extends Notifier<AsyncValue<Set<int>>>`
   - `build()`: load user's favorites from `supabase.from('favorites').select('doctor_id').eq('user_id', currentUserId)`; return `Set<int>` of doctor IDs.
   - `toggle(int doctorId)`: optimistic update + insert/delete row; rollback on error.
2. Update `lib/widgets/doctor_card.dart`:
   - Add a trailing `IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border))` that calls `favoritesProvider.notifier.toggle(doctor.id)`.
3. Create `lib/screens/favorites_screen.dart`:
   - Reads `favoritesProvider` to get the set of IDs.
   - Resolves each ID to a `Doctor` via `ref.watch(doctorByIdProvider(id))`.
   - Renders `ListView` of `DoctorCard`s, or `EmptyState(icon: Icons.favorite_border, title: 'No favorites yet.', subtitle: 'Tap the heart on any doctor to save them.')`.
4. Verify: favorite a doctor → appears in Favorites tab; refresh app → still there; unfavorite → disappears; `flutter analyze` clean.

### 5.5 — Booking Flow
**Shippable outcome:** User can book an appointment; it appears in the Appointments tab.

1. Create `lib/models/appointment.dart`:
   - Fields: `id` (String), `doctorId` (int / String — match schema), `scheduledFor` (DateTime), `status` (enum: pending / confirmed / cancelled), `createdAt` (DateTime).
   - `fromJson` / `toJson`.
2. Create `lib/providers/appointments_provider.dart`:
   - `AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>`
   - `build()`: `supabase.from('appointments').select().eq('user_id', currentUserId).order('scheduled_for', ascending: true)`.
   - `create(doctorId, scheduledFor)`: insert row, refresh list.
3. Create `lib/providers/booking_provider.dart` (form state, not async):
   - `class BookingState { final DateTime? date; final TimeOfDay? time; }`
   - `Notifier<BookingState>` with `setDate` / `setTime` / `reset`.
4. Create `lib/screens/booking_screen.dart`:
   - Reads `doctorByIdProvider(doctorId)` to show the doctor summary at top.
   - Two `ListTile`s with `showDatePicker` (default: tomorrow) and `showTimePicker` (default: 10:00).
   - 6 hardcoded time-slot `ChoiceChip`s for the MVP (09:00, 10:00, 11:00, 14:00, 15:00, 16:00) — choose-one UX is faster than freeform time picker.
   - `FilledButton('Confirm Booking')` calls `appointmentsProvider.notifier.create(doctorId, scheduledFor)` then `context.go('/appointments')`.
   - `EmptyState` if doctor not found.
5. Update `lib/screens/doctor_details_screen.dart`:
   - The existing "Book Appointment" button now navigates: `context.push('/booking/${doctor.id}')`.
6. Create `lib/screens/appointments_screen.dart`:
   - Reads `appointmentsProvider`.
   - Renders `ListView` of cards, each showing: doctor name (joined via `doctorByIdProvider`), formatted date/time (`intl` package), status badge.
   - `EmptyState(icon: Icons.event_busy, title: 'No appointments yet.', subtitle: 'Book your first appointment from a doctor\'s profile.')`.
7. Verify: book an appointment → appears in Appointments tab; refresh → persists; `flutter analyze` clean.

### 5.6 — FilterChips for Specialties
**Shippable outcome:** Home screen shows horizontal FilterChips that filter the doctor list.

1. Create `lib/models/specialty.dart`:
   - `enum Specialty { cardiology, dermatology, pediatrics, orthopedics, generalPractice, dentistry }`
   - Extension with `String get label` and `IconData get icon`.
2. Create `lib/widgets/specialty_chip.dart`:
   - `FilterChip` with label + icon, `selected` state bound to a `selectedSpecialtyProvider` (StateProvider<Specialty?>).
3. Update `lib/screens/home_screen.dart`:
   - Add a horizontal `SingleChildScrollView` of `SpecialtyChip`s between the search bar and the doctor list.
   - Update `filteredDoctorsProvider` to also filter by `selectedSpecialtyProvider` (if non-null).
   - "All" chip at the start to clear the filter.
4. Verify: tap a chip → list filters; tap "All" → list resets; chip selection persists across tab switches (state in provider); `flutter analyze` clean.

### 5.7 — "Near Me" with PostGIS
**Shippable outcome:** "Near Me" icon calls `nearby_doctors` RPC and replaces the home list with results within 5 km.

1. Update `lib/providers/location_provider.dart` (existing): `getCurrentPosition()` is unchanged.
2. Update `lib/screens/home_screen.dart` `_handleNearMe`:
   - On permission grant: get `Position`, call `supabase.rpc('nearby_doctors', params: {lat, lng, radius_km: 5})`, write results to a `nearbyResultsProvider` (StateProvider<List<Doctor>?>).
   - Home screen's `filteredDoctorsProvider` falls back to `nearbyResultsProvider` if non-null.
   - Show `SnackBar('Showing doctors within 5 km.')` on success.
   - On failure or empty results: `EmptyState(icon: Icons.location_off, title: 'No doctors nearby.')`.
3. Verify: on Android emulator, mock location near Bangalore → list filters; on Web (deny permission) → SnackBar as before; `flutter analyze` clean.

---

## 6. Edge Cases & Mitigations

| Edge Case | Mitigation |
|-----------|------------|
| **Supabase unreachable at boot** | Wrap `Supabase.initialize` in try/catch. Show `SplashScreen` with retry button instead of crashing. |
| **Anonymous auth fails** | Same as above — show a screen with a "Retry" button that calls `signInAnonymously` again. |
| **Favorite toggle fails (network)** | `FavoritesNotifier.toggle` does optimistic update; on error, roll back the local set and show a SnackBar "Could not save favorite. Try again." |
| **Empty Favorites tab** | `EmptyState` with friendly copy. |
| **Empty Appointments tab** | `EmptyState` with CTA copy. |
| **Empty nearby search** | `EmptyState(icon: Icons.location_off, title: 'No doctors within 5 km.')` with "Show all doctors" button to clear the filter. |
| **Date / time in the past** | `showDatePicker.firstDate = DateTime.now()`; `showTimePicker` validation if user picks today: must be > now. |
| **Book appointment for non-existent doctor (deep link to `/booking/999`)** | Show `EmptyState(icon: Icons.person_off, title: 'Doctor not found.')`. |
| **Two simultaneous bookings** | Disable "Confirm Booking" button while the `create` future is in flight (use `ref.watch(appointmentsProvider).isLoading`). |
| **Web bottom nav at 600px** | Use `LayoutBuilder` in `BottomNavScaffold` to switch to `NavigationRail` at width >= 600, avoiding both navs rendering at once. |
| **PostGIS RPC throws (column type mismatch)** | Catch in `nearbyDoctorsProvider`, fall back to client-side `Geolocator.distanceBetween` over the full list. |
| **RLS blocks a query** | Catch PostgREST `401`/`403`, show SnackBar "Session expired. Restart the app." |

---

## 7. File-by-File Change Summary

| File | Action |
|------|--------|
| `pubspec.yaml` | Add `supabase_flutter ^2.5.0`, `intl ^0.20.0`; run `flutter pub get`. |
| `lib/env.dart` | **NEW** — reads `SUPABASE_URL` / `SUPABASE_ANON_KEY` from `--dart-define`. |
| `lib/main.dart` | Add `await Supabase.initialize(...)` + `signInAnonymously()` before `runApp`. |
| `lib/models/doctor.dart` | Add `fromJson` / `toJson`. |
| `lib/models/appointment.dart` | **NEW**. |
| `lib/models/specialty.dart` | **NEW** enum. |
| `lib/providers/doctor_provider.dart` | **REFACTOR** to `AsyncNotifierProvider` reading from Supabase. |
| `lib/providers/favorites_provider.dart` | **NEW** `Notifier<AsyncValue<Set<int>>>`. |
| `lib/providers/appointments_provider.dart` | **NEW** `AsyncNotifierProvider`. |
| `lib/providers/booking_provider.dart` | **NEW** form-state `Notifier`. |
| `lib/screens/home_screen.dart` | Remove outer `Scaffold`/`AppBar` (shell owns them); add FilterChips; refactor `_handleNearMe` to use RPC. |
| `lib/screens/doctor_details_screen.dart` | "Book" button now `context.push('/booking/${doctor.id}')`. |
| `lib/screens/booking_screen.dart` | **NEW**. |
| `lib/screens/favorites_screen.dart` | **NEW**. |
| `lib/screens/appointments_screen.dart` | **NEW**. |
| `lib/widgets/bottom_nav_scaffold.dart` | **NEW**. |
| `lib/widgets/specialty_chip.dart` | **NEW**. |
| `lib/widgets/doctor_card.dart` | Add favorite heart `IconButton`. |
| `lib/utils/app_router.dart` | **REFACTOR** to `StatefulShellRoute.indexedStack`. |
| `lib/utils/mock_doctors.dart` | **DELETE** (moved to `supabase/seed.sql`). |
| `supabase/schema.sql` | **NEW** — PostGIS + tables + RLS + RPC. |
| `supabase/seed.sql` | **NEW** — 6 doctors from old mock data. |

---

## 8. Acceptance Criteria

1. **Chrome (Web):** `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` launches with no red console errors. 3 tabs render; `BottomNavigationBar` on narrow viewport, `NavigationRail` on wide.
2. **Android:** `flutter build apk --debug` succeeds. App runs on emulator/device, sign-in completes, doctors load from Supabase.
3. **Deep linking:**
   - Web: `http://localhost:PORT/favorites` opens Favorites tab directly.
   - Android intent: `adb shell am start -W -a android.intent.action.VIEW -d "doctorly://favorites"` opens Favorites tab.
4. **Favorites persist:** favorite a doctor, kill app, relaunch — favorite is still in the list.
5. **Booking flow:** book an appointment → appears in Appointments tab; row shows correct doctor, date, and time; refresh → persists.
6. **PostGIS "Near Me":** on Android emulator with mocked GPS near Bangalore, "Near Me" shows only doctors within 5 km, sorted by distance.
7. **FilterChips:** selecting "Cardiology" filters the list to only Cardiologists; "All" resets.
8. **No layout overflows:** resize Chrome from 320px to 1600px — no yellow/black stripes in dev tools.
9. **Lint:** `flutter analyze` exits clean.
10. **Empty states:** all 3 tabs and "Near Me" with no results show the correct `EmptyState` widget.

---

## 9. Open Questions / Risks

- **Anonymous auth abuse:** Supabase limits anon sessions; for production, real auth is required (out of scope, but document this in the README).
- **Image URLs in seed data:** the 6 `i.pravatar.cc` URLs must be stored in the `doctors.image_url` column; the existing `i.pravatar` issues we fixed in earlier phases (CORS on headless Chrome) still apply on Web.
- **Time zones:** `timestamptz` in PostgreSQL is UTC; `intl` formatting must use the device's local time zone. Test on emulator with a non-UTC time zone.
- **Secrets in `--dart-define`:** acceptable for MVP; move to a backend or `.env` file for production.
- **Schema migration:** no migration tool (e.g., `supabase-cli`) is set up in this phase. The schema is "create only". For future changes, add `supabase` CLI migrations.
