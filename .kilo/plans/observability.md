# Doctorly: Observability Plan

## Current State
- `lib/services/logger.dart` — `package:logging` wrapper; logs to `debugPrint` only.
- `lib/services/error_reporter.dart` — `ErrorReporter` abstraction + `NoopErrorReporter`.
- `lib/providers/error_reporter_provider.dart` — provides `NoopErrorReporter`.
- `lib/widgets/error_boundary.dart` — catches widget errors, calls `errorReporterProvider.report`.
- `lib/main.dart:81-96` — `FlutterError.onError` + `runZonedGuarded` funnel to `LoggerService` and `errorReporterProvider`.
- **No analytics, no crash reporting SDK, no performance monitoring in prod.**

---

## 1. Error Reporting: Vendor Selection

| Criterion | Sentry | Datadog | Crashlytics (Firebase) |
|-----------|--------|---------|------------------------|
| Flutter SDK maturity | Excellent (`sentry_flutter`) | Good (`datadog_flutter_plugin`) | Good (`firebase_crashlytics`) |
| Web support | Yes | Yes | No |
| Self-hostable | Yes (Sentry on-prem) | No | No |
| Free tier | Generous (5k events/mo) | Limited (14-day trial) | Free (unlimited) |
| Performance monitoring | Built-in APM | Built-in APM | No native APM |
| Alerting / issues UI | Excellent | Excellent | Basic |
| DSN secrecy | Public key (like Supabase anon) | Client token (public) | google-services.json (secret) |
| Bundle size impact | ~1MB | ~2MB | ~1.5MB + Firebase core |

**Recommendation: Sentry**

Reasoning:
1. **Web + Android parity** — Doctorly targets both; Crashlytics excludes Web, Datadog is overkill.
2. **DSN is non-secret** — Fits AGENTS.md rule: `--dart-define` only for env name, never keys. Sentry DSN can be injected as `--dart-define=SENTRY_DSN=https://...` because it is a public endpoint key, equivalent to Supabase anon key.
3. **Unified error + performance** — One SDK covers both crash reporting and prod performance traces, avoiding a second vendor.
4. **Self-hostable path** — If privacy requirements change, Sentry on-prem is an option without rewriting instrumentation.

---

## 2. Analytics: Vendor Selection

| Criterion | PostHog | Mixpanel | Amplitude |
|-----------|---------|----------|-----------|
| Self-hostable | Yes | No | No |
| Flutter SDK | Community (`posthog_flutter`) | Official | Official |
| Free tier | Unlimited (self-host) / 1M events/mo (cloud) | 100k users/mo | 10M events/mo |
| Session replay | Yes | No | Limited |
| Feature flags | Yes | Yes | Yes |
| Data residency | Full control | US/EU only | US/EU only |
| Setup complexity | Medium (needs PostHog instance) | Low | Low |

**Recommendation: PostHog (self-hosted or cloud)**

Reasoning:
1. **Self-hostable** — Aligns with Doctorly's control-first posture; no vendor lock-in.
2. **Session replay** — Invaluable for debugging booking flow drop-offs without asking users for screenshots.
3. **Unified product analytics + feature flags** — Future-proof for A/B testing onboarding variants.
4. **Flutter SDK is stable** — `posthog_flutter` is actively maintained.

If self-hosting is deferred, PostHog Cloud (`us.posthog.com`) is acceptable; the API key is a non-secret project token (like Sentry DSN) and can be passed via `--dart-define=POSTHOG_KEY=phc_...`.

---

## 3. Performance Monitoring

| Context | Tool | Rationale |
|---------|------|-----------|
| Dev only | Flutter DevTools | Already built into `flutter run`; covers frame rendering, widget rebuilds, memory snapshots. No extra dependency needed. |
| Prod | Sentry Performance | Included with Sentry SDK; traces screen loads, network requests, and slow frames. No second vendor needed. |

**Plan:**
- **Dev:** Rely on DevTools during active development. Add a `PerformanceOverlay` toggle in debug builds only (gated by `kDebugMode`) if screen-level tracing is needed.
- **Prod:** Enable Sentry `tracesSampleRate` (start at `0.2` — 20% of sessions) to capture slow routes (`/booking`, `/doctor/:id`) and RPC latency (`nearby_doctors`).

---

## 4. User Feedback Loop

**Recommendation: Shake-to-report via Sentry User Feedback + optional in-app form**

Implementation:
1. Add a `GestureDetector` on `MaterialApp` (or a top-level `Scaffold` in `MainApp`) that listens for vertical shake (`velocity > threshold`).
2. On shake: show a modal bottom sheet with:
   - Text field: "What went wrong?"
   - Screenshot button (captures current `RenderRepaintBoundary`)
   - Submit button → calls `Sentry.captureUserFeedback`
3. If Sentry is unavailable (e.g., dev mode), fallback to `mailto:` with pre-filled subject/body.

**Do NOT** implement a custom backend for feedback. Sentry User Feedback attaches to the active error context and surfaces in the Sentry UI alongside stack traces.

---

## 5. Integration Points in Existing Code

### 5.1 `lib/main.dart` — Sentry bootstrap
**Current state:** Lines 15-122 initialize `LoggerService`, load `.env`, initialize Supabase, set `FlutterError.onError` and `runZonedGuarded`.

**Changes (plan only):**
1. Import `package:sentry_flutter/sentry_flutter`.
2. In `main()`, before `runApp`, call `await SentryFlutter.init(...)` with:
   - `dsn: const String.fromEnvironment('SENTRY_DSN')`
   - `tracesSampleRate: 0.2`
   - `enableAutoSessionTracking: true`
   - `beforeSend`: strip PII (email, user_id) if required by privacy policy.
3. Replace `FlutterError.onError` at lines 81-96 with `SentryFlutter.captureException` (Sentry's own `FlutterError` handler).
4. Keep `runZonedGuarded` for async zone errors; `SentryFlutter.init` hooks into it automatically.

### 5.2 `lib/providers/error_reporter_provider.dart` — Wire real implementation
**Current state:** Returns `NoopErrorReporter`.

**Changes (plan only):**
1. Replace `NoopErrorReporter` with `SentryErrorReporter` (new class in `lib/services/error_reporter.dart`) that calls `Sentry.captureException`.
2. Guard with ` Sentry.isEnabled` so dev builds without DSN fall back to noop.

### 5.3 `lib/widgets/error_boundary.dart` — Shake gesture
**Current state:** Catches widget errors, shows "Something went wrong" screen.

**Changes (plan only):**
1. Wrap `Scaffold` in a `GestureDetector` listening for `onVerticalDragEnd` with velocity threshold.
2. On trigger: show feedback bottom sheet.
3. In debug mode, also log to console.

### 5.4 `lib/services/logger.dart` — Structured JSON logs (dev only)
**Current state:** Plain-text `debugPrint` in release; `Level.ALL` in debug.

**Changes (plan only):**
1. Add a `LogConsoleOutput` that emits JSON `{timestamp, level, message, error, stack}` in debug mode.
2. Keep plain-text in release unless Sentry is active (Sentry captures breadcrumbs from `LoggerService` automatically if configured).

### 5.5 `lib/utils/app_router.dart` — Route tracing
**Current state:** Standard `GoRouter` redirects.

**Changes (plan only):**
1. Add a `GoRouter` observer that starts a Sentry `Transaction` named `route /path` on each navigation.
2. Finish the transaction when the page is popped or a new route pushes.

---

## 6. Phased Implementation Order

### Phase 1: Error Reporting (Sentry) — 1 day
1. Add `sentry_flutter: ^7.0.0` to `pubspec.yaml`.
2. Bootstrap in `main.dart` with DSN from `--dart-define`.
3. Replace `error_reporter_provider.dart` `NoopErrorReporter` with Sentry implementation.
4. Verify: trigger a test error in dev → appears in Sentry dashboard.
5. Verify: `flutter analyze` clean.

### Phase 2: Analytics (PostHog) — 1 day
1. Add `posthog_flutter: ^2.0.0` to `pubspec.yaml`.
2. Initialize in `main.dart` with API key from `--dart-define=POSTHOG_KEY=...`.
3. Instrument key events:
   - `app_opened` (on first frame)
   - `doctor_viewed` (on `DoctorDetailsScreen` build)
   - `favorited` / `unfavorited`
   - `booking_created` / `booking_cancelled`
4. Verify: events appear in PostHog Live.

### Phase 3: Performance Monitoring — 1 day
1. Enable Sentry `tracesSampleRate: 0.2`.
2. Add GoRouter observer for route transactions.
3. Add manual `Sentry.startTransaction` around `DoctorsRepository.fetchNearby` RPC.
4. Verify: transaction waterfall shows in Sentry Performance.

### Phase 4: User Feedback (Shake-to-Report) — 0.5 day
1. Add shake gesture detector to `MainApp`.
2. Show bottom sheet with text field + screenshot capture.
3. Submit to Sentry User Feedback.
4. Verify: shake in Android emulator → feedback appears in Sentry.

### Phase 5: Privacy & Secrets Hygiene — 0.5 day
1. Audit all `--dart-define` values in `AGENTS.md` to confirm none are secrets.
2. Confirm Sentry DSN and PostHog key are treated as non-secret config.
3. Add `.env` back to `.gitignore` if removed; confirm no keys in repo.

---

## 7. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Sentry DSN leaked | It is a public client key, not a secret. Treat it like Supabase anon key. |
| PostHog self-host infra cost | Start with PostHog Cloud; migrate to self-host only if data residency requires it. |
| Shake gesture conflicts with scroll | Use `onVerticalDragEnd` with velocity threshold; disable on input fields. |
| Performance overhead of tracing | Keep `tracesSampleRate` at `0.2` in prod; use `1.0` only in staging. |
| PII in breadcrumbs | Implement `beforeSend` breadcrumb hook to strip email/user_id. |

---

## 8. Verification Checklist

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — existing tests still pass
- [ ] Sentry test error appears in dashboard within 60s
- [ ] PostHog `app_opened` event appears in Live within 30s
- [ ] Sentry route transaction appears in Performance tab
- [ ] Shake gesture opens feedback form in debug build
- [ ] No secrets in `pubspec.yaml`, `lib/main.dart`, or `.env` files

---

## 9. Out of Scope
- Crashlytics (excluded because no Web support)
- Datadog (excluded because cost/complexity outweighs benefits at this stage)
- Amplitude (excluded because no self-host option)
- Custom feedback backend (use Sentry only)
