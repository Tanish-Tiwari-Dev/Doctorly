# Doctorly MVP — Implementation Plan

## 1. Goal & Non-Goals

**Goal**
Build a minimal viable product (MVP) of "Doctorly" that lets users browse a list of specialized doctors and discover which ones are near them. Targets: Android + Web.

**Non-Goals (out of scope for MVP)**
- Real user authentication / accounts
- Real backend API or database
- Payments, appointments, or telemedicine
- Push notifications
- Doctor reviews or ratings submission
- Multi-language / i18n

**Assumptions**
- Mock data set represents doctors in a single city (e.g., Bangalore) so "Near Me" is always meaningful.
- User accepts that Web geolocation may fail outside HTTPS/localhost.

---

## 2. Dependencies to Add (`pubspec.yaml`)

| Package | Purpose | Notes |
|---------|---------|-------|
| `flutter_riverpod` ^2.6.1 | State management | Use `flutter_riverpod` (includes Riverpod + Flutter devtools hooks). No code-gen needed for MVP; use `Notifier` / `AsyncNotifier` manually. |
| `go_router` ^14.3.0 | Routing & deep-linking | Declarative routes; supports Android intents + Web URL updates out of the box. |
| `geolocator` ^13.0.2 | Geolocation | Used for "Near Me" distance calculation. |
| `url_strategy` ^0.3.0 | Web URL strategy | Optional but recommended for Web to remove hash (`/#/`) and use clean paths with GoRouter. |
| `flutter_lints` ^6.0.0 | Linting | Already present. Keep. |
| `cupertino_icons` ^1.0.8 | Icons | Already present via Flutter SDK. No extra icon package required for MVP; use Material / Cupertino icons. |

**Platform-specific config required**
- **Android:** Add location permissions to `android/app/src/main/AndroidManifest.xml`:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
- **Web:** `geolocator_web` is pulled in transitively. Ensure app runs on `localhost` or HTTPS for geolocation API to work.

---

## 3. Folder Structure

```
lib/
├── main.dart
├── models/
│   ├── doctor.dart
│   └── specialty.dart
├── screens/
│   ├── home_screen.dart
│   ├── doctor_list_screen.dart
│   ├── doctor_detail_screen.dart
│   └── nearby_screen.dart
├── widgets/
│   ├── doctor_card.dart
│   ├── specialty_chip.dart
│   ├── empty_state.dart
│   └── responsive_layout.dart
├── providers/
│   ├── doctor_provider.dart
│   └── location_provider.dart
└── utils/
    ├── constants.dart
    ├── app_router.dart
    └── location_service.dart
```

**Rationale**
- `models/`: Plain Dart data classes. No logic.
- `screens/`: One widget per page/route. Thin; delegates state to providers and UI to widgets.
- `widgets/`: Reusable composite widgets shared across screens.
- `providers/`: All Riverpod providers and async state machines.
- `utils/`: Router config, constants (mock DB), and platform services (location helper).

---

## 4. Phased Implementation Steps

### Phase 1: Setup & Mock Data Models
**Shippable outcome:** App compiles, mock doctor data is loaded, and a simple list can be rendered in debug mode.

1. Update `pubspec.yaml` with the dependencies listed above.
2. Create `lib/models/doctor.dart` and `lib/models/specialty.dart`.
   - `Doctor`: `id`, `name`, `specialty`, `latitude`, `longitude`, `address`, `experienceYears`, `rating`, `consultationFee`, `photoUrl`.
   - `Specialty`: `id`, `name`, `icon`.
3. Create `lib/utils/constants.dart` with a hardcoded `List<Doctor>` (8–12 entries) clustered around one city center.
4. Create `lib/providers/doctor_provider.dart` exposing an `AsyncValue<List<Doctor>>` provider that reads from the constants.
5. Verify:
   - `flutter pub get`
   - `flutter analyze` passes
   - `flutter run -d chrome` launches (home screen still shows placeholder text).

### Phase 2: UI & Routing Shell
**Shippable outcome:** Users can navigate between Home, Doctor List, and Doctor Details on both Android and Web. Deep links work.

1. Create `lib/utils/app_router.dart` with GoRouter config:
   - `/` → `HomeScreen`
   - `/doctors` → `DoctorListScreen`
   - `/doctors/:id` → `DoctorDetailScreen`
   - `/nearby` → `NearbyScreen` (placeholder for now)
   - Use `ShellRoute` to scaffold persistent bottom navigation on mobile.
2. Create `lib/widgets/doctor_card.dart` (tap → push `/doctors/:id`).
3. Create `lib/screens/home_screen.dart`:
   - Search bar (UI-only for now), specialty chips (horizontal scroll), "Near Me" action button.
4. Create `lib/screens/doctor_list_screen.dart`:
   - Consumes `doctorProvider`.
   - Renders `ListView` of `DoctorCard`s.
5. Create `lib/screens/doctor_detail_screen.dart`:
   - Reads `Doctor` from router state parameters or provider by ID.
   - Displays full info.
6. Wire `main.dart` to use `ProviderScope` + `MaterialApp.router`.
7. Verify:
   - Navigation works on Android emulator and Chrome.
   - Android back button closes screens.
   - Web browser back/forward updates URL.
   - `flutter analyze` passes.

### Phase 3: Responsive Design & "Near Me" Mock Logic
**Shippable outcome:** Layout adapts to screen width; "Near Me" computes real distances from the device to mock doctors.

1. Create `lib/widgets/responsive_layout.dart`:
   - Wraps content in `LayoutBuilder`.
   - Breakpoints: `< 600` mobile, `600–1200` tablet, `> 1200` desktop/Web.
   - Mobile: `Scaffold` + `BottomNavigationBar`.
   - Desktop/Web: `Row` with sidebar nav + `ConstrainedBox(maxWidth: 1200)`.
2. Update `DoctorListScreen` to use `GridView` on tablet/desktop (`crossAxisCount: 2` or `3`) and `ListView` on mobile.
3. Create `lib/utils/location_service.dart`:
   - `Future<Position?> getCurrentPosition()` using `geolocator`.
   - Handles `LocationPermission.denied`, `deniedForever`, and service disabled.
4. Create `lib/providers/location_provider.dart`:
   - `AsyncValue<Position?>` provider that calls the service.
   - Exposes a `refreshLocation()` method.
5. Update `lib/screens/nearby_screen.dart`:
   - Reads location provider.
   - On location ready, calculates distance to each doctor using `Geolocator.distanceBetween()`.
   - Sorts doctors by distance ascending.
   - Renders results using the same `DoctorCard` widget.
6. Add empty / error / permission-denied states using `lib/widgets/empty_state.dart`.
7. Verify:
   - Resize Chrome window to validate responsive breakpoints.
   - On Android emulator, send mock location via emulator controls and verify sorting changes.
   - Deny Web geolocation permission and verify graceful fallback.
   - `flutter analyze` passes.

---

## 5. Edge Cases & Mitigations

| Edge Case | Mitigation |
|-----------|------------|
| **Web geolocation denied / unavailable** | Show `EmptyState` with message "Location unavailable. Showing all doctors." and fall back to unsorted list. Do not crash. |
| **Android permission permanently denied** | Catch `LocationPermission.deniedForever`; show dialog prompting user to open app settings. |
| **Location services disabled on device** | Catch exception from `geolocator`; show snackbar / empty state with retry button. |
| **No doctors in mock data** (should not happen, but defensive) | `doctorProvider` filters out nulls; UI shows `EmptyState` if list is empty. |
| **Deep link to invalid `/doctors/:id`** | GoRouter `redirect` or error screen; show "Doctor not found" page. |
| **Web resize to arbitrary width** | `LayoutBuilder` + `ConstrainedBox` prevents horizontal overflow; grid columns clamp at max 3. |
| **Slow device / large mock list** | MVP list is small (8–12); no pagination needed yet. If list grows, wrap in `ListView.builder`. |

---

## 6. Acceptance Criteria

1. **Chrome (Web):** `flutter run -d chrome` launches. No red console errors. User can navigate all routes, resize window, and see layout adapt.
2. **Android:** `flutter build apk --debug` completes without errors. App installs and runs on emulator/device.
3. **Routing:** Deep linking works:
   - Web: `http://localhost:8080/doctors/1` opens doctor detail directly.
   - Android: `adb shell am start -W -a android.intent.action.VIEW -d "doctorly://doctors/1" com.example.doctorly` opens doctor detail.
4. **Near Me:** On emulator with mocked GPS coordinates, "Near Me" sorts doctors by computed distance and updates when location changes.
5. **Lint / Format:** `flutter analyze` exits with no issues. Code formatted with `dart format`.
6. **Responsive:**
   - Width < 600px: single-column list + bottom nav.
   - Width 600–1200px: 2-column grid + rail or bottom nav.
   - Width > 1200px: 3-column grid + sidebar nav, centered content.
