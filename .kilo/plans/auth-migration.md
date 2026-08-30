# Doctorly: Anonymous → Real Auth Migration Plan

## Goal
Replace anonymous auth with email/OTP, Google OAuth, and Apple Sign-In while preserving existing anonymous favorites and appointments via database-level account merging.

---

## 0. Database Migration (run once in Supabase Dashboard → SQL Editor)

### 0.1 `profiles` table

```sql
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  is_anonymous boolean not null default false,
  anonymous_token text unique,
  last_merge_attempt_at timestamptz,
  created_at timestamptz not null default now()
);

-- Allow users to read their own profile row
create policy "profiles read own" on public.profiles
  for select to authenticated using (auth.uid() = user_id);

-- Allow anon insert so the Flutter client can seed the anonymous profile
create policy "profiles insert anon" on public.profiles
  for insert to anon with check (is_anonymous = true);

comment on table public.profiles is 'Lightweight extension of auth.users for Doctorly-specific auth metadata.';
```

### 0.2 `merge_anonymous_data` function

```sql
create or replace function public.merge_anonymous_data(
  p_old_anon_id uuid,
  p_new_user_id uuid
)
returns table (
  transferred_favorites bigint,
  transferred_appointments bigint,
  errors text[]
)
language plpgsql
security definer
as $$
declare
  v_favs bigint;
  v_appts bigint;
  v_errors text[] := '{}';
begin
  -- Transfer favorites
  update public.favorites
     set user_id = p_new_user_id
   where user_id = p_old_anon_id;
  get diagnostics v_favs = row_count;

  -- Transfer appointments
  update public.appointments
     set user_id = p_new_user_id
   where user_id = p_old_anon_id;
  get diagnostics v_appts = row_count;

  -- Mark the anonymous profile as merged
  update public.profiles
     set is_anonymous = false,
         last_merge_attempt_at = now()
   where user_id = p_old_anon_id;

  return query select v_favs, v_appts, v_errors;
end;
$$;

grant execute on function public.merge_anonymous_data(uuid, uuid) to anon, authenticated;
```

### 0.3 Backfill existing anonymous users (run after deploying the function)

```sql
insert into public.profiles (user_id, is_anonymous)
select id, true
from auth.users
where is_anonymous is distinct from true
  and id not in (select user_id from public.profiles)
  and email is null;
```

---

## 1. Flutter Integration Points

### 1.1 `lib/providers/auth_provider.dart` — StreamProvider + merge trigger

**Current state:** `authProvider` is a `StreamProvider` at line 19 that yields `AuthState` on every `onAuthStateChange` event.

**Required changes (plan only):**
1. Add a `StateProvider<String?>` named `anonymousUserIdProvider` initialized to `null`. This caches the anonymous user ID before a real-auth transition.
2. In `authProvider`'s stream listener, when a new session arrives:
   - If `anonymousUserIdProvider` is non-null **and** the new session's user ID differs from the cached anonymous ID:
     - Call `Supabase.instance.client.rpc('merge_anonymous_data', params: { 'p_old_anon_id': cachedId, 'p_new_user_id': newId })`
     - On success: clear `anonymousUserIdProvider` and invalidate `favoritesProvider` and `appointmentsProvider`
     - On failure: log the error but do **not** block the sign-in; surface a non-fatal SnackBar via a global scaffold messenger key
3. Add a helper method `cacheAnonymousUserId(String id)` that writes to `anonymousUserIdProvider`.
4. After the merge RPC completes, log `transferred_favorites` and `transferred_appointments` counts via `LoggerService`.

**Exact file/line reference:** `lib/providers/auth_provider.dart:19` (StreamProvider definition) and `lib/providers/auth_provider.dart:32` (`onAuthStateChange` listener).

### 1.2 `lib/screens/auth_screen.dart` — Email/OTP + OAuth buttons

**Current state:** `_submit()` at lines 37-46 calls `signInWithPassword` or `signUp`. There is no OAuth UI.

**Required changes (plan only):**
1. Replace the password-based flow with **email/OTP magic link** as the primary path:
   - Call `client.auth.signInWithOtp(email: email, emailRedirectTo: ...)` for login
   - Call `client.auth.signUp(email: email, emailRedirectTo: ...)` for sign-up
   - After calling the RPC, show a SnackBar: "Check your email for the login link"
   - Remove `_passwordController`, `_obscurePassword`, and password validation
2. Add two new buttons below the email field:
   - **Continue with Google** — calls `client.auth.signInWithOAuth(Provider.google)` (Supabase handles the OAuth flow; on Web this opens a popup, on Android it uses a Custom Tab)
   - **Continue with Apple** — gated behind `Theme.of(context).platform == TargetPlatform.iOS`; calls `client.auth.signInWithIdToken(provider: Provider.apple, idToken: ...)` after obtaining the token via the `sign_in_with_apple` package
3. After any successful OAuth redirect (detected by `authProvider`'s `onAuthStateChange`), the merge flow in `auth_provider.dart` handles data transfer automatically.
4. Keep the existing `_humanizeAuthError` mapping for OTP-specific errors (e.g., `invalid_email`, `over_email_send_rate_limit`).

**Exact file/line references:**
- `lib/screens/auth_screen.dart:37` — replace `signInWithPassword` block
- `lib/screens/auth_screen.dart:42` — replace `signUp` block
- `lib/screens/auth_screen.dart:14-20` — remove password-related state fields
- `lib/screens/auth_screen.dart:202-234` — remove password text field, add OAuth buttons

### 1.3 `lib/main.dart` — Remove anonymous auto-sign-in

**Current state:** Lines 69-76 call `Supabase.instance.client.auth.signInAnonymously()` unconditionally after initialization.

**Required changes (plan only):**
1. Delete the entire `if (initialized) { ... signInAnonymously() ... }` block at lines 69-76.
2. After `Supabase.initialize()` (line 58), read `client.auth.currentSession`. If it is non-null, the user is returning from a real auth session; do nothing. If null, the app stays unauthenticated and the router redirects to `/onboarding`.
3. Remove the `TODO(#8)` comment at line 47.

**Exact file/line reference:** `lib/main.dart:69-76`.

---

## 2. Google OAuth Setup

### 2.1 Supabase Dashboard
1. Authentication → Providers → Google → Enable
2. Add **Client ID** and **Client Secret** from Google Cloud Console
3. Add authorized redirect URIs:
   - Web: `https://<your-project>.supabase.co/auth/v1/callback`
   - Android: `com.example.doctorly:/oauth2redirect` (replace with actual package name)

### 2.2 Android (`android/app/build.gradle.kts`)
1. Add `com.google.android.gms:play-services-auth` dependency (or use `google_sign_in` package if direct integration is preferred; Supabase's built-in OAuth uses the system browser and does not require `google_sign_in`).
2. Ensure the manifest has an intent filter for the redirect URI:
   ```xml
   <intent-filter>
     <action android:name="android.intent.action.VIEW" />
     <category android:name="android.intent.category.DEFAULT" />
     <category android:name="android.intent.category.BROWSABLE" />
     <data android:scheme="com.example.doctorly" android:host="oauth2redirect" />
   </intent-filter>
   ```
3. Upload `google-services.json` to CI secrets; inject via Gradle.

### 2.3 Web (`web/index.html`)
1. In Supabase Dashboard → Authentication → URL Configuration, add `http://localhost:8080` (dev) and production domain to **Allowed URLs**.
2. No additional JS changes required; Supabase's `signInWithOAuth` handles the popup automatically.

### 2.4 Flutter side
- Replace the Google button's `onPressed` with:
  ```dart
  await ref.read(supabaseClientProvider).auth.signInWithOAuth(
    Provider.google,
    redirectTo: 'com.example.doctorly:/oauth2redirect', // Android
  );
  ```
- On Web, Supabase opens a popup; the auth state change listener in `auth_provider.dart` picks up the session when the user returns.

---

## 3. Apple Sign-In Setup

**Scope:** iOS only. Do not show the Apple button on Android or Web.

### 3.1 Supabase Dashboard
1. Authentication → Providers → Apple → Enable
2. Configure **Services ID**, **Team ID**, **Key ID**, and **Private Key** from Apple Developer account.

### 3.2 iOS (`ios/Runner/Info.plist`)
1. Add `Sign in with Apple` capability in Xcode (Signing & Capabilities → + Capability).
2. Add `CFBundleURLTypes` for the Supabase callback URL if not auto-generated.

### 3.3 Flutter dependencies
1. Add `sign_in_with_apple: ^6.0.0` to `pubspec.yaml` dev_dependencies.
2. In the Apple button handler:
   - Call `SignInWithApple.getAppleIDCredential(...)` to obtain `identityToken`
   - Pass the token to Supabase:
     ```dart
     await ref.read(supabaseClientProvider).auth.signInWithIdToken(
       provider: Provider.apple,
       idToken: identityToken,
     );
     ```
3. Gate the Apple button widget behind `Platform.isIOS` so it is invisible on other platforms.

---

## 4. Token Refresh Strategy

### 4.1 Automatic refresh (Supabase default)
- `supabase_flutter` auto-refreshes access tokens via a background timer. No code changes required for the happy path.

### 4.2 Manual refresh on 401 (repositories)
- In each repository method (`doctors_repository.dart`, `favorites_repository.dart`, `appointments_repository.dart`), wrap Supabase calls in a retry block:
  1. Catch `AuthException` or HTTP 401
  2. Call `Supabase.instance.client.auth.refreshSession()` and await it
  3. Retry the original request once
  4. If retry fails, surface `AsyncValue.error` with a localized "Session expired. Please sign in again." message
- Do **not** swallow 401s silently; the user must be redirected to login if refresh fails.

### 4.3 Session expiration UI
- In `lib/utils/app_router.dart:28`, if `authProvider` emits `isSignedIn == false` while the user is on a protected route, redirect to `/onboarding`.
- Show a SnackBar on the previous screen before redirecting: "Your session expired."

---

## 5. Sign-Out Flow

### 5.1 Provider changes
- Add `signOut()` to a new `AuthRepository` (or directly in `auth_provider.dart` if repository creation is deferred):
  ```dart
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    // Providers will auto-update via onAuthStateChange
  }
  ```

### 5.2 UI trigger
- Add a "Sign Out" button in a profile/settings screen (create if absent). If no settings screen exists, add it to the bottom nav scaffold or doctor details screen for now.
- `onPressed`: call `signOut()`, then `context.go('/onboarding')`.

### 5.3 State cleanup
- After sign-out, manually invalidate: `doctorListProvider`, `favoritesProvider`, `appointmentsProvider`, `nearbyResultsProvider`, `selectedSpecialtyProvider`, `searchQueryProvider`.
- Clear any cached anonymous user ID if present.

---

## 6. Phased Implementation Order

### Phase A: Database + anonymous cleanup (1-2 days)
1. Run the SQL in §0 in Supabase SQL Editor.
2. Delete the anonymous sign-in block in `lib/main.dart:69-76`.
3. Verify `flutter analyze` is clean and the app launches to onboarding without auto-sign-in.

### Phase B: Email/OTP auth (1-2 days)
1. Refactor `lib/screens/auth_screen.dart` to use `signInWithOtp` / `signUp` instead of password flow.
2. Remove password fields and validation.
3. Verify magic link flow end-to-end in Web (localhost) and Android emulator.

### Phase C: Anonymous → real merge (1 day)
1. Add `anonymousUserIdProvider` and merge logic in `lib/providers/auth_provider.dart`.
2. Test: create anonymous favorites, sign in with email, verify favorites persist under the new account.
3. Add logging for `transferred_favorites` and `transferred_appointments` counts.

### Phase D: Token refresh + sign-out (1 day)
1. Add 401 retry logic in all repositories.
2. Implement `signOut()` and UI trigger.
3. Verify session expiration redirects to onboarding.

### Phase E: Google OAuth (1-2 days)
1. Configure Supabase Dashboard + Google Cloud.
2. Add Android intent filter and Web allowed URLs.
3. Add "Continue with Google" button in `auth_screen.dart`.
4. Test on Android emulator and Chrome.

### Phase F: Apple Sign-In (1-2 days, iOS only)
1. Add Xcode capability and Supabase provider config.
2. Add `sign_in_with_apple` package and button gated to iOS.
3. Test on iOS simulator or physical device.

---

## 7. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Anonymous user ID is lost on app kill before merge | Cache anonymous ID in `SharedPreferences` alongside the in-memory provider; read it on app startup. |
| Merge RPC fails silently | Always log `errors[]` array returned by the function; if non-empty, surface a SnackBar offering manual support contact. |
| OAuth popup blocked by browser | Use `signInWithOAuth` with `redirectTo` on Web; fallback to full-page redirect if popup is unavailable. |
| Token refresh loop | Retry only once; on second 401, treat as hard failure and redirect to login. |
| Apple Sign-In unavailable on older iOS versions | Gate button with `Platform.isIOS`; show only on iOS 13+. |

---

## 8. Verification Checklist

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — existing tests still pass
- [ ] Anonymous flow removed from `main.dart`
- [ ] `auth_screen.dart` has zero `signInWithPassword` references
- [ ] `profiles` table exists in Supabase
- [ ] `merge_anonymous_data` function exists and returns correct row counts
- [ ] Email/OTP sign-in works on Web and Android
- [ ] Google OAuth works on Web and Android
- [ ] Apple Sign-In works on iOS (if built)
- [ ] Favorites + appointments survive anonymous → real account transition
- [ ] 401 triggers silent token refresh; expired session redirects to onboarding
- [ ] Sign-out clears local state and returns to `/onboarding`

---

## 9. Out of Scope (defer to later phases)
- Phone/OTP SMS auth (requires Twilio or Supabase SMS)
- Multi-factor authentication (MFA)
- Social auth providers beyond Google + Apple (Facebook, Twitter, etc.)
- Biometric re-authentication on app resume
- Account deletion / data export (GDPR)
