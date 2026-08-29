# Phase 7 — Mobbin UI Overhaul (Plan)

## Part 1: Theme, Bottom Nav, Home Screen

### 0. File-Path Discrepancy (must resolve before implementation)

The user referenced `@lib/screens/main_shell.dart`, but **that file does not exist**. The bottom-navigation shell in this codebase lives at `lib/widgets/bottom_nav_scaffold.dart` and is wired into `lib/utils/app_router.dart` via `StatefulShellRoute.indexedStack`.

**Recommendation (single question):** keep the file where it is. Do not move it into `lib/screens/`, because `app_router.dart` already imports it from `widgets/` and GoRouter wiring is non-trivial to change.

→ **Action by implementer:** no rename. Edit `lib/widgets/bottom_nav_scaffold.dart` in place.

---

### 1. Theme (`lib/main.dart`)

**Current state:** `ThemeData` uses `ColorScheme.fromSeed(seedColor: Colors.teal)` and a bare `GoogleFonts.interTextTheme()`. Card elevation is 2 with 14px radius.

**Changes:**

1. **Scaffold background:** `scaffoldBackgroundColor: Colors.white` (pure `#FFFFFF`).
2. **Color scheme:** switch seed from `Colors.teal` to **`Color(0xFF0A6EBD)`** (deep blue accent from the Phase-7 design tokens). Set:
   - `primary: Color(0xFF0A6EBD)`
   - `onPrimary: Colors.white`
   - `surface: Color(0xFFF5F5F5)`
   - `onSurface: Color(0xFF0F172A)` (near-black text)
   - `secondary: Color(0xFF64748B)` (textSecondary)
   - `outline: Color(0xFFE5E7EB)` (border)
3. **Text theme:** keep `GoogleFonts.interTextTheme()` and apply explicit weights to match the token table:
   - `displayLarge`: w700, 32 (used for home header).
   - `headlineMedium`: w700, 24.
   - `titleLarge`: w600, 20.
   - `bodyLarge`: w400, 16.
   - `labelLarge`: w600, 14.
4. **Card theme:** `elevation: 0`, `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))`, `color: Colors.white`, `surfaceTintColor: Colors.transparent` (so Material 3 does not tint).
5. **AppBar theme:** keep `elevation: 0`, `centerTitle: false`, `backgroundColor: Colors.white`, `foregroundColor: Color(0xFF0F172A)`. `titleTextStyle` = `GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))`.
6. **InputDecorationTheme** (so search bar inherits pill shape globally):
   - `filled: true`, `fillColor: Color(0xFFF5F5F5)`.
   - `border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)`.
   - `enabledBorder: same`, `focusedBorder: same with 2px primary outline at 0.3 opacity`.
   - `contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)`.
   - `hintStyle: GoogleFonts.inter(color: Color(0xFF64748B))`.
7. **FilterChipTheme:**
   - `backgroundColor: Color(0xFFF5F5F5)`, `selectedColor: Color(0xFF0A6EBD)`.
   - `labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Color(0xFF0F172A))`.
   - `selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)`.
   - `shape: StadiumBorder()`, `showCheckmark: false`, `side: BorderSide.none`.
   - `padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8)`.
8. **NavigationBarTheme** (mobile) **and** **NavigationRailTheme** (wide):
   - `backgroundColor: Colors.white`, `indicatorColor: Color(0xFF0A6EBD).withOpacity(0.12)`, `surfaceTintColor: Colors.transparent`.
   - Icon sizes 24; active color = `primary`, inactive = `Color(0xFF64748B)`.
   - Label text style: `GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)`.
9. **Do not touch** the `dotenv`/`Supabase.initialize` block, `Env`, or `runApp(ProviderScope(...))`.

---

### 2. Bottom Nav (`lib/widgets/bottom_nav_scaffold.dart`)

**Constraint:** keep the file location. The `LayoutBuilder` mobile-list vs web-grid logic for the home screen is inside `home_screen.dart`, not here. The shell's `LayoutBuilder` only switches between `NavigationBar` (mobile) and `NavigationRail` (≥ 600px).

**Changes:**

1. **Remove inline `AppBar` theming concerns** — these are now handled globally by `AppBarTheme`.
2. **Mobile branch (`NavigationBar`):**
   - `backgroundColor: Colors.white` (already from theme, but be explicit).
   - `elevation: 0`, `surfaceTintColor: Colors.transparent`.
   - `height: 72`, `labelBehavior: NavigationDestinationLabelBehavior.alwaysShow`.
   - Destinations: 3 existing items (Home / Favorites / Appointments). Use **outlined** icons when inactive and **filled** when selected (already correct in current code: `Icons.home_outlined` → `Icons.home`, etc.).
3. **Wide branch (`NavigationRail`):**
   - `backgroundColor: Colors.white`, `indicatorColor: Color(0xFF0A6EBD).withOpacity(0.12)`.
   - `selectedIconTheme: IconThemeData(color: primary)`, `unselectedIconTheme: IconThemeData(color: textSecondary)`.
   - `selectedLabelTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, color: primary)`.
   - `unselectedLabelTextStyle: GoogleFonts.inter(color: textSecondary)`.
   - `labelType: NavigationRailLabelType.all`.
4. **Keep** the `VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE5E7EB))` and the `Row` structure.
5. **Keep** `_onTap` and the `StatefulNavigationShell` wiring — do not change routing behavior.
6. **Do not** convert to a floating-pill nav yet. That is part of a later phase; the user explicitly asked for a "clean, minimal" bar with proper active/inactive states.

---

### 3. Home Screen (`lib/screens/home_screen.dart`)

**Constraint:** preserve all provider reads (`doctorListProvider`, `filteredDoctorsProvider`, `searchQueryProvider`, `selectedSpecialtyProvider`, `locationServiceProvider`, `nearbyResultsProvider`, `supabaseClientProvider`) and all RPC logic. The `LayoutBuilder` mobile-list vs web-grid block at lines 196–227 stays intact.

**Changes:**

1. **Remove the `AppBar`** (it currently says "Doctorly" with w700). Replace with an inline header at the top of the body:
   - `Padding(EdgeInsets.fromLTRB(20, 16, 20, 8))` wrapping a `Column(crossAxisAlignment: start)`:
     - First line: `Text('Find your doctor', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))`.
     - Second line: `SizedBox(height: 4)`, `Text('Book trusted specialists near you', style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF64748B)))`.
2. **Move the "Near Me" action** from the AppBar `actions` slot into the header row's right side (still gated on `_nearbyActive`):
   - Wrap the existing two `IconButton`s (`Icons.near_me` / `Icons.location_off`) in a `Container(margin: EdgeInsets.only(top: 4))` so they align with the title baseline. Same tooltips, same `onPressed` handlers.
3. **Search bar:** the existing `TextField` keeps its controller and `onChanged` wiring. Because the new `InputDecorationTheme` provides pill shape + `fillColor: #F5F5F5` + no border globally, the inline `border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))` is removed; let the theme handle it. Change the inline radius to match (28) only if theme override is not applied. Keep the `prefixIcon`, `suffixIcon` clear, and `hintText`. Adjust outer padding to `EdgeInsets.fromLTRB(20, 8, 20, 8)`.
4. **Specialty chip row:** no logic changes. The `FilterChip` theme will now automatically apply the pill shape and selected/unselected colors. Remove the `style: GoogleFonts.inter(...)` from labels (theme provides it).
5. **Doctor cards (`lib/widgets/doctor_card.dart`):** rebuild the outer container — see §4.
6. **LayoutBuilder block (lines 196–227):** unchanged. Mobile still uses `ListView.separated` with `DoctorCard`; wide still uses `GridView.builder` with the same `crossAxisCount` formula and `childAspectRatio: 2.6`.
7. **Outer column padding:** set `Padding(EdgeInsets.zero)` on the column root; let individual sections own their horizontal padding (header 20, search 20, chip row already 16, list/grid 16/20).
8. **Empty states:** keep `EmptyState` widget usage as-is. The `Icons.cloud_off` / `Icons.search_off` / `Icons.location_off` icons inherit color from `EmptyState`'s implementation — verify it uses `textSecondary` (if not, file a follow-up; do not change `EmptyState` in Part 1).
9. **Loading and error states:** unchanged. `CircularProgressIndicator` is fine (theme defaults color to primary).

---

### 4. Doctor Card (`lib/widgets/doctor_card.dart`)

The user explicitly specified the shadow / radius / typography. Rebuild the outer wrapper from a `Card` to a `Container`:

1. Replace `Card(...)` with:
   - `Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0xFF0F172A).withOpacity(0.05), blurRadius: 10, spreadRadius: 0, offset: Offset(0, 4))]), margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: ...)`
2. Inside, use a `Material(type: MaterialType.transparency, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => context.push('/doctor/${doctor.id}'), child: Padding(...)))` so ripple is clipped to the rounded shape and tap behavior is preserved.
3. Layout inside `Padding(EdgeInsets.all(12))`:
   - `Row(children: [...])`:
     - Leading: keep the `Hero(tag: 'doctor-avatar-${doctor.id}', child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(doctor.imageUrl), ...))` exactly as today.
     - Middle column (`Expanded`):
       - `Text(doctor.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))` — one line, `maxLines: 1, overflow: ellipsis`.
       - `SizedBox(height: 2)`.
       - `Text(doctor.specialty, style: GoogleFonts.inter(fontSize: 13, color: Color(0xFF64748B)))` — one line.
       - `SizedBox(height: 4)`.
       - Optional address/clinic line in 12px `textSecondary` (only if the model exposes it; current model has `address` per earlier code — use it if present, otherwise skip).
     - Trailing column (existing rating + km + heart `IconButton`): tighten spacing; rating `GoogleFonts.inter(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))`, distance `12px` `textSecondary`, heart `IconButton(icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Color(0xFFEF4444) : Color(0xFF64748B)), visualDensity: VisualDensity.compact)`.
4. **Margin handling:** since cards now own their own horizontal margin (16), **remove** the `margin: EdgeInsets.symmetric(horizontal: 16)` from the list/grid item builder so cards do not double-pad. The `ListView.separated` and `GridView.builder` padding already covers this.
5. **Preserve** favorites provider interaction and `context.push('/doctor/${doctor.id}')` navigation.
6. **Hero tag conflict in grids:** the current `Hero` tag works for the list but in a grid, multiple avatars with the same tag framework won't collide per route — this is unchanged from before; no fix in Part 1.

---

### 5. Out-of-Scope (do not change in Part 1)

- `lib/utils/app_router.dart` (routing logic).
- `lib/providers/*` (Supabase / Riverpod state).
- `lib/models/*` (data models).
- `lib/screens/doctor_details_screen.dart`, `booking_screen.dart`, `favorites_screen.dart`, `appointments_screen.dart`.
- `lib/widgets/empty_state.dart` (unless it breaks the look — then a minimal color tweak only).
- `lib/widgets/specialty_chip.dart` logic (only the inline label `style:` is removed because the theme now provides it; the `Padding(right: 8)` between chips stays).
- The `LayoutBuilder` in `home_screen.dart` that switches list vs grid.

---

### 6. Validation Plan

After implementation, run (in order):

1. `flutter pub get` — confirm no new packages are needed (`google_fonts` is already a dependency).
2. `flutter analyze` — must exit 0 with no new warnings. Paste the full output to the user.
3. `flutter run -d chrome` — open DevTools console; confirm no red errors, no Material 3 tinting regressions, search bar renders as a pill, filter chips are pill-shaped and selected chip is `#0A6EBD`, doctor cards show the soft shadow.
4. Resize the Chrome window across 411 / 800 / 1280 px:
   - < 600 → single-column list, bottom nav.
   - 600–1024 → 2-column grid, navigation rail.
   - > 1024 → 2- to 4-column grid, navigation rail, content centered.
5. Tap a filter chip — verify the selected state turns blue and filters the list.
6. Type in the search bar — verify the filtered list updates (this exercises `searchQueryProvider`, which must not regress).
7. Tap "Near Me" — verify the Supabase RPC call still works (this exercises `locationServiceProvider` and `supabaseClientProvider`, which must not regress).
8. `flutter build apk --debug` — confirm Android still compiles.

---

### 7. Risks & Open Questions

- **Risk:** `FilterChip` theme + existing inline `Padding(right: 8)` may produce a chip whose `selectedColor` is overridden by the theme but whose text color still comes from inline `labelStyle`. The implementer should remove inline `style:` from the chip labels to let the theme win.
- **Risk:** `Card` → `Container` change in `DoctorCard` removes the default Material tap-feedback; replaced by `InkWell` (covered in §4 step 2). If `InkWell` is forgotten, taps silently no-op on grid items.
- **Risk:** The `Hero` tag `'doctor-avatar-${doctor.id}'` is duplicated across list and grid views of the same doctor on the same screen; not a Part-1 regression (pre-existing) but worth noting.
- **Open question for the user (recommended to resolve before Part 2):** is the "Overlapping Card" layout on Doctor Details a hard requirement for the next phase, or is the current detail screen acceptable as-is? It is out of scope for Part 1.

---

### 8. Tasks (ordered, shippable independently)

1. Edit `lib/main.dart` — apply ThemeData changes (§1, steps 1–8). Run `flutter analyze`.
2. Edit `lib/widgets/bottom_nav_scaffold.dart` — apply NavigationBar/NavigationRail theming (§2). Run `flutter analyze`.
3. Edit `lib/widgets/specialty_chip.dart` — remove inline label `style:` from chips so theme provides it. Run `flutter analyze`.
4. Edit `lib/widgets/doctor_card.dart` — rebuild outer Container with shadow + 16px radius; replace `Card` with `Container` + `InkWell`; tighten typography (§4). Run `flutter analyze`.
5. Edit `lib/screens/home_screen.dart` — remove AppBar; add inline header; move Near Me action; clean search-bar border; let LayoutBuilder block stay untouched (§3). Run `flutter analyze`.
6. Final `flutter analyze` pass and paste the output to the user. `flutter run -d chrome` smoke test. `flutter build apk --debug` confirmation.
