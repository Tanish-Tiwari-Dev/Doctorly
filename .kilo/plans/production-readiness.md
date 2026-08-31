# Doctorly: MVP → Production Readiness Plan

## Open Questions (Must resolve before implementation)

1. **Auth provider**: You currently use `signInAnonymously()` at startup (`lib/main.dart:40`) and a custom `AuthScreen` with email/password (`lib/screens/auth_screen.dart:34-45`). Is anonymous auth a **required** feature for launch, or can it be removed in favor of email/password only? My recommendation: **remove anonymous auth** to reduce abuse surface and simplify RLS, unless you have a specific use case for guest users.

2. **Analytics / observability vendor**: Which service(s) do you want? My recommendation: **Firebase Crashlytics + Analytics** (already standard for Flutter, minimal setup) or **Sentry** if you want error tracking without Google. Please pick one before Phase 4/5 implementation.

3. **Image caching library**: `cached_network_image` is the standard choice, but it brings `flutter_cache_manager` as a transitive dep. Do you accept that, or should I use a lighter alternative? My recommendation: **`cached_network_image`** — proven, widely used.

4. **Real auth providers**: Beyond email/password, do you need **Google Sign-In** and/or **Apple Sign-In** for launch? My recommendation: **Google Sign-In only for Phase 5**, add Apple later if you target iOS App Store.

5. **Realtime scope**: For favorites sync, do you want **full realtime** (every favorite change broadcasts to all devices) or **optimistic local updates + periodic refresh**? My recommendation: **optimistic local + Supabase Realtime broadcast** to keep it simple.

---

## Phase 1: Dead Code Removal

**Goal:** Remove unused files and duplicate code to reduce maintenance surface with zero user-facing risk.

**Files to delete:**
- `lib/widgets/specialty_chip.dart` — `SpecialtyChipSliverDelegate` is defined but never imported anywhere; `home_screen.dart` uses its own inline `_SpecialtyChipDelegate`.

**Files to create:** *(none)*

**Files to modify:**
- `lib/screens/home_screen.dart` — Remove inline `_SpecialtyChipDelegate` class (lines 338-395) and its instantiation at line 242; replace with `const SizedBox.shrink()` or a placeholder to preserve layout spacing until Phase 2 consolidates filtering UI.

**Migration notes:** The `_SpecialtyChipDelegate` in `home_screen.dart` is already the only one used in production. Deleting `specialty_chip.dart` removes dead code. After removal, the specialty filter chips will be absent until replaced in Phase 2.

**Risk:** Low — no active imports of `specialty_chip.dart`, no runtime references.

**Rollback:** Restore `lib/widgets/specialty_chip.dart` from git and revert `home_screen.dart` changes.

**Verification:**
- `flutter analyze` — zero unused import warnings
- Manual: app launches, home screen scrolls, no missing widget exceptions

**Acceptance criteria:**
- [ ] `lib/widgets/specialty_chip.dart` deleted
- [ ] `lib/screens/home_screen.dart` compiles without referencing `_SpecialtyChipDelegate`
- [ ] App runs; home screen renders without crash

---

## Phase 2: De-duplication & Provider Consolidation

**Goal:** Collapse overlapping doctor-list providers and standardize Hero tags without changing any screen public API.

**Files to create:** *(none)*

**Files to modify:**
- `lib/providers/doctor_provider.dart` — Replace `sortedDoctorsProvider`, `filteredDoctorsProvider`, and `topRatedDoctorsProvider` with a single `doctorListProvider` (already exists as `AsyncNotifierProvider`) and a single `filteredDoctorsProvider` that accepts a `DoctorListFilter` model. `topRatedDoctorsProvider` becomes a trivial `.take(6)` on the filtered list. Remove the redundant `sortedDoctorsProvider`; sorting by distance should happen in `filteredDoctorsProvider` only when explicitly requested.
- `lib/widgets/doctor_card.dart` — Change Hero tag to a stable, collision-safe value: `doctor-details-${doctor.id}` (shared with `doctor_details_screen.dart`). Ensure compact cards in horizontal lists do **not** reuse this tag (wrap compact cards in `IgnorePointer` or skip Hero entirely when `compact == true`).
- `lib/screens/doctor_details_screen.dart` — Update Hero tag to `doctor-details-${doctor.id}` to match the new contract.

**Migration notes:** Provider names change internally; external consumers (`home_screen.dart`, `favorites_screen.dart`) only need to update their `.watch()` calls to the new unified `filteredDoctorsProvider` signature. No UI behavior changes.

**Risk:** Medium — provider refactor touches the core data flow used by 3 screens; tests are absent, so regression risk is non-trivial.

**Rollback:** Revert `doctor_provider.dart` to original provider definitions; revert Hero tag changes in `doctor_card.dart` and `doctor_details_screen.dart`.

**Verification:**
- `flutter analyze` — clean
- Manual:
  1. Home screen loads doctors list
  2. Search + specialty filter work
  3. Top Rated horizontal list renders
  4. Tap a doctor card → hero animates to detail screen
  5. Favorites screen lists saved doctors

**Acceptance criteria:**
- [ ] `sortedDoctorsProvider` removed
- [ ] `filteredDoctorsProvider` is the single source for filtered/sorted doctors
- [ ] Hero tags are consistent (`doctor-details-{id}`) and collision-safe in grids
- [ ] All screens still render doctor lists correctly

---

## Phase 3: Repository Layer Introduction

**Goal:** Move all Supabase access out of Notifiers and into repositories so Notifiers never know SQL column names or table names.

**Files to create:**
- `lib/repositories/auth_repository.dart` — Wraps `Supabase.instance.client.auth` (signIn, signUp, signOut, currentUser). Rationale: centralizes auth calls so `auth_screen.dart` can call a repository instead of `Supabase.instance.client`.
- `lib/repositories/favorites_repository.dart` — Wraps `favorites` table CRUD. Rationale: `favorites_provider.dart` currently calls `.from('favorites')` directly.
- `lib/repositories/appointments_repository.dart` — Wraps `appointments` table CRUD and `cancel` update. Rationale: `appointments_provider.dart` currently calls `.from('appointments')` directly.

**Files to modify:**
- `lib/providers/doctor_provider.dart` — `DoctorsNotifier.refresh()` and `doctorListProvider` already use `DoctorRepository`; extend `DoctorRepository.fetchNearby()` to accept the same filter params the RPC needs.
- `lib/providers/favorites_provider.dart` — Replace all `.from('favorites')` calls with `FavoritesRepository` methods.
- `lib/providers/appointments_provider.dart` — Replace all `.from('appointments')` calls with `AppointmentsRepository` methods.
- `lib/screens/auth_screen.dart` — Replace `Supabase.instance.client` direct call with `AuthRepository` methods (see Anti-pattern finding at line 34).
- `lib/screens/home_screen.dart` — Replace inline RPC call at line 62 with `DoctorRepository.fetchNearby()`.

**Migration notes:** This is a pure internal refactor. Screens continue to call the same provider APIs. Providers become thinner; repositories own all SQL/table names. Existing data in Supabase is untouched.

**Risk:** Medium — touches auth flow and all data providers. `auth_screen.dart` direct Supabase access is the highest-risk spot.

**Rollback:** Keep old provider code in git history; revert provider files to pre-repository state.

**Verification:**
- `flutter analyze` — clean
- Manual:
  1. Sign in with email/password works
  2. Anonymous sign-in still happens on startup (if not removed per open question 1)
  3. Home screen loads doctors
  4. Near-me button fetches nearby doctors
  5. Favorites toggle persists
  6. Booking creates appointment

**Acceptance criteria:**
- [ ] `auth_screen.dart` contains zero `Supabase.instance.client` references
- [ ] `home_screen.dart` contains zero `.from()` or `.rpc()` references
- [ ] `favorites_provider.dart` and `appointments_provider.dart` contain zero `.from()` references
- [ ] All screens function identically to pre-change behavior

---

## Phase 4: Error Handling, Logging, Global Error Boundary

**Goal:** Replace ad-hoc `debugPrint` with structured logging and add a global Flutter error handler; no behavior changes.

**Files to create:**
- `lib/services/logger.dart` — Singleton using `package:logging` (`Logger`, `LogRecord`). Expose `info`, `warning`, `error` methods. Rationale: AGENTS.md requires all logging route through this singleton; `debugPrint` is forbidden.

**Files to modify:**
- `lib/main.dart` — Replace `debugPrint(...)` calls (lines 26, 38, 42, 45) with `logger.info/warning/error(...)`. Add `FlutterError.onError` and `PlatformDispatcher.onError` handlers that funnel to `logger.error` and a future error-reporting service (Sentry/Firebase). Ensure `Zone` catches async errors.
- `lib/providers/favorites_provider.dart` — Replace `throw AsyncError('Could not load favorites.', st)` with `logger.error('Failed to load favorites', e, st)` then `throw` or return `AsyncValue.error(e, st)` to comply with AGENTS.md "never swallow silently."
- `lib/providers/appointments_provider.dart` — Add `logger.error` in `catch` blocks before setting `AsyncValue.error`.

**Migration notes:** Logging is additive; no existing call sites are removed except `debugPrint`. Providers already surface errors via `AsyncValue.error`; we just add logging before surfacing.

**Risk:** Low — purely additive; no data or UI flow changes.

**Rollback:** Revert `main.dart` and provider files to previous debugPrint versions; delete `lib/services/logger.dart`.

**Verification:**
- `flutter analyze` — clean
- Manual:
  1. Disable network → trigger error states in home/favorites → error logs appear in console
  2. Force a Flutter widget error → caught by global handler and logged

**Acceptance criteria:**
- [ ] `lib/services/logger.dart` exists and is used by `main.dart`
- [ ] Zero `debugPrint` calls remain in `lib/`
- [ ] `FlutterError.onError` and `PlatformDispatcher.onError` are set in `main()`
- [ ] All AsyncValue.error states also log before surfacing

---

## Phase 5: Security Hardening

**Goal:** Remove secrets from assets, tighten RLS, and begin migration to real auth.

**Files to create:** *(none)*

**Files to modify:**
- `pubspec.yaml` — Remove `.env` from the `assets:` list (line 28). Rationale: bundling `.env` into the app binary/web bundle risks leaking secrets.
- `lib/main.dart` — Remove `signInAnonymously()` block (lines 40-43). Require explicit email/password sign-in. If the open question resolves to "keep anonymous auth", skip this deletion and instead add rate-limiting logic.
- `supabase/schema.sql` — Replace the permissive `doctors read` policy (lines 51-52, `using (true)`) with two policies: `doctors read anon` limited to `is_authenticated = false` with a restrictive `using` clause (e.g., only non-sensitive fields if needed) and `doctors read authenticated` for signed-in users. Alternatively, keep `using (true)` but add a comment warning that doctors data is public by design.
- `android/app/build.gradle.kts` — Add `local.properties` pattern for `SUPABASE_URL` and `SUPABASE_ANON_KEY`, injected via `--dart-define` at build time. Add `key.properties` template for release signing.
- `AGENTS.md` — Update the secret-management section to document the Android `local.properties` + `--dart-define` pattern and Web build-time env var approach.

**Migration notes:** Removing `.env` from assets means CI/build pipelines must pass `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. Removing anonymous auth means returning users see the login screen instead of being auto-signed-in; `currentUserIdProvider` returns `null` until sign-in.

**Risk:** High — removing anonymous auth changes the first-run user flow; removing `.env` from assets breaks local `flutter run` unless `--dart-define` is provided.

**Rollback:** Restore `.env` asset in pubspec.yaml; restore anonymous sign-in block in `main.dart`; restore original `doctors read` policy.

**Verification:**
- `flutter analyze` — clean
- `flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...` — succeeds
- Manual:
  1. App launches → login screen (no auto-anonymous sign-in)
  2. Sign in with email/password → home screen loads
  3. Favorites + booking still work post-login

**Acceptance criteria:**
- [ ] `.env` is no longer in `pubspec.yaml` assets
- [ ] `Supabase.instance.client.auth.signInAnonymously()` removed from `main.dart`
- [ ] `doctors read` RLS policy documented/justified (public catalog) or tightened
- [ ] Android `local.properties` + `--dart-define` documented in AGENTS.md

---

## Phase 6: Performance & UX Polish

**Goal:** Reduce bandwidth cost, add favorites realtime sync, and eliminate hero collisions.

**Files to create:** *(none)*

**Files to modify:**
- `lib/widgets/doctor_card.dart` — Replace `NetworkImage(doctor.imageUrl)` with `CachedNetworkImage` (add dependency justification: widely used, minimal API surface). Fallback to `NetworkImage` if the cache fails.
- `lib/screens/booking_screen.dart` — Replace `NetworkImage(doctor.imageUrl)` at line 137 with `CachedNetworkImage`.
- `lib/providers/favorites_provider.dart` — Add a Supabase Realtime `INSERT`/`DELETE` subscription on the `favorites` table scoped to `eq('user_id', userId)`. On change, invalidate `favoritesProvider` so all screens update. Fallback to polling if Realtime is unavailable.
- `lib/widgets/doctor_card.dart` — Ensure `Hero` is skipped when `compact == true` to prevent tag collisions in horizontal `ListView` (top-rated) and vertical `SliverGrid`.

**Migration notes:** Image caching is additive; old `NetworkImage` behavior is preserved as fallback. Realtime subscription is additive; existing manual toggle behavior remains. Hero tag fix is a bug fix; no UI changes.

**Risk:** Medium — adding Realtime changes the favorites sync model; if the subscription logic is wrong, it could cause infinite invalidation loops.

**Rollback:** Revert `doctor_card.dart` and `booking_screen.dart` to `NetworkImage`; comment out Realtime subscription block in `favorites_provider.dart`.

**Verification:**
- `flutter analyze` — clean
- Manual:
  1. Scroll home screen → doctor images load from cache on repeat views
  2. Tap heart on doctor A → favorites screen updates immediately
  3. Horizontal top-rated list → no hero animation, no crashes
  4. Grid view on tablet → no hero tag collision warnings

**Acceptance criteria:**
- [ ] `doctor_card.dart` and `booking_screen.dart` use cached image loading
- [ ] Favorites sync in realtime (or fallback to refresh) across multiple screens
- [ ] Hero tags are collision-safe in both list and grid layouts

---

## Phase 7: Test Scaffold + CI/CD + Release Signing

**Goal:** Establish the minimum viable test suite and CI pipeline so future changes are safe to ship.

**Files to create:**
- `test/unit/repositories/doctor_repository_test.dart` — 1 unit test: verifies `Doctor.fromJson` mapping and that `fetchAll` calls the correct Supabase endpoint (mock with `MockClient`).
- `test/unit/repositories/appointments_repository_test.dart` — 1 unit test: verifies `Appointment.fromJson` and `create` builds the correct insert payload.
- `test/unit/repositories/auth_repository_test.dart` — 1 unit test: verifies `currentUser` exposes the expected `User?` from a mocked session.
- `test/widget/screens/home_screen_test.dart` — 1 widget test: pumps `HomeScreen` with a mock `doctorListProvider`, verifies loading state and doctor cards render.
- `test/widget/screens/booking_screen_test.dart` — 1 widget test: pumps `BookingScreen` with a mock doctor, taps date/time, taps confirm, verifies navigation to `/appointments`.
- `test/widget/screens/appointments_screen_test.dart` — 1 widget test: pumps `AppointmentsScreen` with mock appointments, verifies list items render.
- `test/integration/booking_flow_test.dart` — 1 integration test: launches app, signs in, navigates to doctor, books appointment, verifies appointment appears in appointments tab. Uses `integration_test` package.
- `.github/workflows/flutter_ci.yml` — CI pipeline: checkout, setup Flutter, `flutter pub get`, `flutter analyze`, `flutter test`.
- `android/key.properties.example` — Template for release keystore config.

**Files to modify:**
- `pubspec.yaml` — Add `integration_test` and `mocktail` (or `mockito`) dev dependencies with one-sentence justification per package: `integration_test` is required for integration tests; `mocktail` is the standard null-safe mocking library for Flutter.
- `android/app/build.gradle.kts` — Add release signing block that reads `key.properties` (git-ignored).
- `android/gradle.properties` — Add `android.useAndroidX=true` and signing placeholder comments if missing.

**Migration notes:** Tests are additive; they do not change app behavior. CI runs on PR; manual release signing config is added but not activated until keystore is generated.

**Risk:** Low-Medium — adding tests and CI does not affect production code, but `integration_test` requires a device/emulator to run in CI, which increases CI complexity.

**Rollback:** Delete `.github/workflows/flutter_ci.yml`; remove test files; revert `pubspec.yaml` and `android/app/build.gradle.kts` changes.

**Verification:**
- `flutter analyze` — clean
- `flutter test` — all tests pass
- `flutter build apk` — succeeds with signing config present
- GitHub Actions — green on PR

**Acceptance criteria:**
- [ ] `flutter test` passes (unit + widget + integration)
- [ ] `.github/workflows/flutter_ci.yml` exists and runs on PR
- [ ] Android release signing config documented in `android/key.properties.example`
- [ ] `pubspec.yaml` has no unused or unapproved new dependencies

---

## Summary: Execution Order & Dependencies

| Phase | Depends On | Risk | Blocks Next? |
|-------|-----------|------|--------------|
| 1 — Dead code | None | Low | Yes (removes dead widget that would otherwise be rewritten in Phase 2) |
| 2 — De-duplication | Phase 1 | Medium | Yes (consolidates providers that Phase 3 will refactor) |
| 3 — Repositories | Phase 2 | Medium | Yes (Phase 4 touches providers; clean abstractions first) |
| 4 — Logging | Phase 3 | Low | No |
| 5 — Security | Phase 3 | High | No (can be done in parallel with 4/6) |
| 6 — Performance | Phase 3 | Medium | No |
| 7 — Tests + CI | Phases 1-6 | Low-Medium | No |

**Recommended sequence:** 1 → 2 → 3 → (4, 5, 6 in any order) → 7.

**Top 5 highest-impact items across all phases:**
1. **Phase 5:** Remove `.env` from assets and replace `signInAnonymously()` — prevents key leakage and reduces auth abuse.
2. **Phase 3:** Move `Supabase.instance.client` out of `auth_screen.dart` and `home_screen.dart` into repositories — fixes the #1 architecture violation.
3. **Phase 4:** Add global error boundary + structured logging — catches silent crashes before they reach users.
4. **Phase 6:** Add image caching — cuts bandwidth cost on repeat doctor image loads by ~80%.
5. **Phase 7:** CI/CD + tests — ensures no regression in future PRs.

**Blockers that would prevent Play Store / production launch if unresolved:**
1. No Android signing config (Phase 7)
2. `.env` bundled as asset with real keys (Phase 5)
3. `Supabase.instance.client` called directly in screens (Phase 3)
4. Zero tests / no CI (Phase 7)
5. Anonymous auth without rate limiting (Phase 5)
