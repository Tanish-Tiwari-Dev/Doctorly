# Doctorly — Supabase Integration Reference

## Status: Implemented in Phase 5

This document is a **reference of the current Supabase integration**, not an
outstanding work list. The schema, RLS, Flutter providers, and the PostGIS
RPC are all already implemented. Items marked "Gap" below are deliberate
follow-ups, not blockers.

---

## 1. Database Schema

All tables live in the `public` schema. The PostGIS extension must be enabled
in the Supabase Dashboard before running the schema.

### 1.1 `public.doctors`

| Column         | Type                              | Notes |
|----------------|-----------------------------------|-------|
| `id`           | `uuid primary key default gen_random_uuid()` | Supabase-generated, surfaced as `String` in Flutter |
| `name`         | `text not null`                   | |
| `specialty`    | `text not null`                   | Free-form string; matched against `Specialty.label` in `lib/models/specialty.dart` |
| `location`     | `geography(Point, 4326) not null` | PostGIS geography; constructed via `ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography` |
| `address`      | `text`                            | Optional |
| `rating`       | `numeric(2,1)`                    | e.g. 4.8 |
| `image_url`    | `text`                            | |
| `availability` | `text`                            | Free-form ("Available Today") |
| `created_at`   | `timestamptz not null default now()` | |

**Indexes** (`supabase/schema.sql:22-23`):
- `doctors_location_gix` — GIST on `location` for `ST_DWithin` / `ST_Distance` performance.
- `doctors_specialty_idx` — btree on `specialty` for the FilterChip query.

### 1.2 `public.favorites`

Composite-key join table.

| Column       | Type                                              |
|--------------|---------------------------------------------------|
| `user_id`    | `uuid not null references auth.users(id) on delete cascade` |
| `doctor_id`  | `uuid not null references public.doctors(id) on delete cascade` |
| `created_at` | `timestamptz not null default now()`              |
|              | `primary key (user_id, doctor_id)`                |

The composite primary key prevents duplicate favorites for the same
(user, doctor) pair and is what the optimistic `toggle` in
`FavoritesNotifier` relies on.

### 1.3 `public.appointments`

| Column          | Type                                              | Notes |
|-----------------|---------------------------------------------------|-------|
| `id`            | `uuid primary key default gen_random_uuid()`      | |
| `user_id`       | `uuid not null references auth.users(id) on delete cascade` | |
| `doctor_id`     | `uuid not null references public.doctors(id) on delete cascade` | |
| `scheduled_for` | `timestamptz not null`                            | Stored as UTC; Flutter converts to local via `toLocal()` in `appointments_screen.dart:50`. |
| `status`        | `text not null default 'pending' check (status in ('pending','confirmed','cancelled'))` | |
| `created_at`    | `timestamptz not null default now()`              | |

Index: `appointments_user_idx (user_id, scheduled_for)` for fast
per-user chronological reads.

### 1.4 PostGIS RPC: `nearby_doctors`

Defined in `supabase/schema.sql:87-122`. Signature:

```sql
public.nearby_doctors(
  lat double precision,
  lng double precision,
  radius_km double precision default 5
)
returns table (
  id uuid, name text, specialty text, rating numeric,
  image_url text, availability text, distance_m double precision
)
```

Uses `ST_DWithin` for the radius filter and `ST_Distance` for sorting.
Granted to `anon` and `authenticated`.

---

## 2. Row Level Security

All three tables have `enable row level security`.

### 2.1 `doctors` — public read

```sql
create policy "doctors read" on public.doctors
  for select to anon, authenticated using (true);
```

Anyone (signed in or anonymous) can read the directory. Writes require the
service role (admin / SQL editor), so the Flutter client never inserts here.
**Gap:** no policy for `insert` / `update` — intentional, but documented
in the SQL so future readers don't assume RLS will block writes silently.

### 2.2 `favorites` — per-user

```sql
select:  auth.uid() = user_id
insert:  with check (auth.uid() = user_id)
delete:  using  (auth.uid() = user_id)
```

No `update` policy — favorite rows are immutable; un-favoriting is a delete.

### 2.3 `appointments` — per-user, full CRUD

`select`, `insert`, `update`, `delete` all gated on `auth.uid() = user_id`.
`update` exists to support a future "cancel" flow (which the Flutter
`AppointmentsNotifier.cancel` already calls, but the UI does not yet expose).

### 2.4 Anonymous sessions

`main.dart:18-22` calls `supabase.auth.signInAnonymously()`. This produces
a real `auth.users.id` that RLS policies accept, so anon users get their
own private favorites/appointments even before any login UI is added.

---

## 3. Flutter Integration

### 3.1 Initialization (`lib/main.dart`)

- `WidgetsFlutterBinding.ensureInitialized()` before `Supabase.initialize`.
- `Env.supabaseUrl` and `Env.supabaseAnonKey` come from `--dart-define`
  (`lib/env.dart`).
- `signInAnonymously()` is wrapped in try/catch; failure is non-fatal —
  providers will surface errors via `AsyncValue.error`.
- `Supabase.initialize` currently uses the deprecated `anonKey` parameter;
  a `// ignore_for_file: deprecated_member_use` is in place until
  supabase_flutter ships `publishableKey`.

### 3.2 Provider pattern

All Supabase access goes through one shared client:

```dart
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
```

Plus:

```dart
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(supabaseClientProvider).auth.currentUser?.id,
);
```

Every other provider depends on these two.

### 3.3 Doctors (`lib/providers/doctor_provider.dart`)

- `DoctorsNotifier extends AsyncNotifier<List<Doctor>>` — `build()` reads
  the full table ordered by `name`.
- `Doctor.fromJson` maps the row to a `Doctor`; the PostGIS `location`
  column is **not** deserialized into the Flutter `Doctor` — distance is
  carried as a derived `distance_m` column from the RPC, not stored.
- Derived providers: `doctorByIdProvider` (family), `sortedDoctorsProvider`,
  `filteredDoctorsProvider` (combines search + specialty + nearby state).

### 3.4 Favorites (`lib/providers/favorites_provider.dart`)

- `FavoritesNotifier extends AsyncNotifier<Set<String>>` — `build()`
  selects `doctor_id` for the current user.
- `toggle(doctorId)` does **optimistic update + rollback on error**:
  1. Mutate `state` immediately.
  2. Issue insert / delete.
  3. On exception, restore the prior set and `rethrow` so the UI can show
     a SnackBar (see `doctor_card.dart:64-73` and
     `doctor_details_screen.dart:36-48`).
- `isFavorite(id)` is a synchronous convenience for widgets that already
  have the state in scope.

### 3.5 Appointments (`lib/providers/appointments_provider.dart`)

- `AppointmentsNotifier extends AsyncNotifier<List<Appointment>>` — `build()`
  selects all rows for the user ordered by `scheduled_for asc`.
- `create(doctorId, scheduledFor)` inserts a row and calls
  `ref.invalidateSelf()` to refetch. Status defaults to `'pending'`.
- `cancel(appointmentId)` sets status to `'cancelled'`. No UI calls this
  yet (gap).

### 3.6 Near Me (`lib/screens/home_screen.dart:30-75`)

- `_handleNearMe` calls `LocationService.requestPermission()` →
  `LocationService.getCurrentPosition()` → `supabase.rpc('nearby_doctors',
  params: {lat, lng, radius_km: 5.0})`.
- Result list is written to `nearbyResultsProvider` (a
  `StateProvider<List<Doctor>?>`); the home screen shows a
  "Clear nearby" icon while the override is active.
- Errors degrade to the existing "Location denied" SnackBar; empty results
  show the `EmptyState` widget with `Icons.location_off`.

---

## 4. File Structure

```
lib/
├── main.dart                              # Supabase.initialize + signInAnonymously
├── env.dart                               # SUPABASE_URL / SUPABASE_ANON_KEY from --dart-define
├── models/
│   ├── doctor.dart                        # fromJson, copyWith, String id
│   ├── appointment.dart                   # enum AppointmentStatus
│   └── specialty.dart                     # enum mapped against doctors.specialty
├── providers/
│   ├── doctor_provider.dart               # supabaseClientProvider, currentUserIdProvider,
│   │                                      # doctorListProvider (AsyncNotifier), doctorByIdProvider,
│   │                                      # sortedDoctorsProvider, filteredDoctorsProvider,
│   │                                      # searchQueryProvider, selectedSpecialtyProvider,
│   │                                      # nearbyResultsProvider
│   ├── favorites_provider.dart            # FavoritesNotifier (optimistic toggle)
│   ├── appointments_provider.dart         # AppointmentsNotifier (create / cancel)
│   ├── booking_provider.dart              # form-state only (date + time)
│   └── location_provider.dart             # LocationService wrapper
└── utils/
    └── location_service.dart              # requestPermission + getCurrentPosition

supabase/
├── schema.sql                             # extensions, tables, indexes, RLS, RPC, grants
└── seed.sql                               # 6 Bangalore doctors
```

### Repository layer

**Gap (intentional, not implemented):** there is no `DoctorsRepository`,
`FavoritesRepository`, or `AppointmentsRepository` abstraction. Notifiers
call `ref.read(supabaseClientProvider).from(...)` directly. This is
acceptable for the MVP (single data source, no swappability requirement),
but if Phase 6 adds caching, offline support, or a second data source,
introduce a `lib/repositories/` folder with one class per table and have
the notifiers depend on the repository via a Riverpod provider.

---

## 5. Open Questions / Risks

| Topic | Note |
|-------|------|
| `anonKey` deprecation | Track `supabase_flutter` for the `publishableKey` migration; remove the `// ignore_for_file` line when available. |
| Anonymous session lifetime | Supabase may rotate anon tokens; persist the session via `persistSession` (default true). Add a recovery screen if the token expires. |
| Image URLs in `doctors.image_url` | The 6 `i.pravatar.cc` URLs in `supabase/seed.sql` still CORS-fail in some headless browsers; not a runtime issue in Chrome or Android. |
| Real auth | No login UI. `currentUserIdProvider` is always the anon user. Before launch, add email / OAuth sign-in and migrate anon favorites. |
| `appointments.update` RLS | Already in place but the "Cancel appointment" UI is not wired (`AppointmentsNotifier.cancel` exists). |
| Realtime | Not enabled. Adding `client.channel('public.favorites').on(..., filter: user_id=eq.$userId).subscribe()` would let the heart fill in instantly if favorites are modified from another device. Defer to Phase 6. |
| Schema migrations | `schema.sql` is "create only". For Phase 6+ add `supabase` CLI migrations in `supabase/migrations/`. |

---

## 6. Verification

Already proven by `flutter analyze` + `flutter build web` passing in the
Phase 5 implementation turn. Additional runtime checks (require a
configured Supabase project):

1. Run `supabase/schema.sql` then `supabase/seed.sql` in the Dashboard.
2. `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
3. Home shows 6 doctors; tap heart on one → appears in Favorites tab.
4. `select * from favorites;` in SQL editor shows the row.
5. Book an appointment → `select * from appointments;` shows the row with
   the correct `scheduled_for` and `status='pending'`.
6. Tap "Near Me" with location permission granted → only doctors within
   5 km appear.
