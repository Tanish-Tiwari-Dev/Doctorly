# Doctorly Premium Home UI — Implementation Plan

## Verified Baseline (current code vs. request claims)

| Claim in request | Actual code | Status |
|---|---|---|
| Color tokens: white bg, #0A6EBD primary, #F5F5F5 surface, Inter font | White cards ✓, `0xFF0A6EBD` ✓, **no `0xFFF5F5F5` anywhere** ✗, `GoogleFonts.inter()` ✓ | Discrepancy — see Decision D1 |
| "Near Me" moved to top right | Already top-right in existing `home_screen.dart:164–176` | Already done — polish, don't move |
| Header subtitle "Hi, Welcome back 👋" (14px / #64748B) | Currently shows "Book trusted specialists near you" (14px / #64748B) | Change text only |
| Title "Find your doctor" 28px w700 #0F172A | Present, unchanged (`home_screen.dart:146`) | OK |
| State libs | `flutter_riverpod ^2.6.1`, `go_router ^14.3.0`, `geolocator ^13.0.2`, `google_fonts ^7.0.1`, `supabase_flutter ^2.5.0` | Confirmed |

> **Decision log** (resolved; implementation agent must apply):
> - **D1 — Surface color (missing #F5F5F5):** Set `HomeScreen` `Scaffold(backgroundColor: Color(0xFFF5F5F5))` and keep `DoctorCard` backgrounds `Colors.white`. Rationale: floating-card-on-subtle-surface is the Spotify/YT premium idiom. No other surface needs gray.
> - **D2 — Header reading order (Z-pattern):** Top line `"Hi, Welcome back 👋"` 14px w400 #64748B, then `"Find your doctor"` 28px w700 #0F172A, then Near Me icon top-right. (Welcome line above headline — Z-pattern starts upper-left.)
> - **D3 — Near Me:** Keep in header `Row`'s trailing slot. Wrap in `IconButton` with 48×48 min tap target; add `tooltip: 'Near Me'`.
> - **D4 — Layout engine:** Convert `HomeScreen` body from `Column+Expanded` → `CustomScrollView`. All existing state (`filteredDoctorsProvider`, `searchQueryProvider`, `nearbyResultsProvider`), search controller, and the Supabase RPC flow in `_handleNearMe` are preserved unchanged; only the *render tree* changes.
> - **D5 — Top Rated carousel source:** Add `topRatedDoctorsProvider` = `doctorListProvider` sorted by `rating` desc, take first 6. (No new RPC; pure client sort.)
> - **D6 — "Available Today" data:** `Doctor.availability` is `String`. Define a non-breaking helper: `bool get isAvailableToday => availability.trim().toLowerCase().contains('today');` Display badge only when true. **Verification item V2** below to confirm live Supabase token values.
> - **D7 — Carousel card reuse:** `DoctorCard` gains an optional `bool compact` flag (tighter padding, clipped text). Default remains the full premium card.

---

## 1. Header Redesign (Z-Pattern)

Rebuild the top section as the first `SliverToBoxAdapter` (no `AppBar`) so the header scrolls away on scroll (YT feed pattern), while Near Me stays reachable:

```
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hi, Welcome back 👋', style: Inter(14px / w400 / #64748B)),
        Text('Find your doctor',      style: Inter(28px / w700 / #0F172A)),
      ]),
    ),
    NearMeIconButton(),   // 48×48 tap target, top-aligned margin 4
  ],
)
```

- Spacing: `SizedBox(height: 4)` between the two Text lines.
- Horizontal padding: `EdgeInsets.symmetric(horizontal: 20, vertical: 16)`.
- **Z-pattern note:** The eye path is welcome → headline → Near Me (right) → search bar → chips → carousel → list. Do **not** insert hero images here; preserve negative space (Spotify "breathing room" principle) — `padding top 16` before the welcome line.

## 2. Search Bar Elevation (Glassmorphism / Soft UI)

Replace the plain `TextField` decoration with a floating container:
- Outer: `Container` padding `EdgeInsets.symmetric(horizontal: 16)`, margin `EdgeInsets.fromLTRB(20, 8, 20, 12)`.
- `BoxDecoration` → `color: Colors.white`, `borderRadius: BorderRadius.circular(14)`,
  `BoxShadow`:
  ```
  BoxShadow(color: Color(0xFF0F172A).withOpacity(0.04),
           blurRadius: 6, offset: Offset(0, 2))
  BoxShadow(color: Color(0xFF0F172A).withOpacity(0.06),
           blurRadius: 24, offset: Offset(0, 8))
  ```
- `InputDecoration`: transparent fill, no underline (`border: InputBorder.none`), prefix `Icon(Icons.search, size: 20, color: #94A3B8)`, hint `"Search doctors, specialties…"` (`GoogleFonts.inter`, 14px / #94A3B8).
- Keep all existing `onChanged` → `searchQueryProvider.notifier.state` logic intact. This is purely a decoration change (D7 / V1 touch-free for state).

## 3. SpecialtyChip Polish (YouTube pattern)

- Convert `SpecialtyChipRow` from a plain `ListView` into a **sticky pinned header**:
  - New widget `SpecialtyChipSliverDelegate extends SliverPersistentHeaderDelegate` (height = 64, `automaticallyImplyInsets = false`).
  - Interior identical to current `SpecialtyChipRow` (`FilterChip` + horizontal `ListView`).
  - `pinned: true` so it sticks on scroll (YouTube chip bar behavior).
- Selected state:
  - `backgroundColor: #0A6EBD` (0xFF0A6EBD), `labelStyle: #FFFFFF`, `elevation: 0`, `shape: StadiumBorder(side: BorderSide.none)`.
- Unselected state:
  - `backgroundColor: #F1F5F9`, `labelStyle: #334155`, `elevation: 0`, `shape: StadiumBorder(BorderSide(color: #E2E8F0))`.
- Tap target: `FilterChip` already ≥ 32×32; ensure whole chip meets 48×48 via `VisualDensity(vertical: 0.5, horizontal: 1.0)` and minimum `padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)`.
- **Sticky caveat:** chips must remain scrollable horizontally even when pinned — the `ListView(scrollDirection: horizontal)` inside the delegate already supports this; ensure `NeverScrollableScrollPhysics` is NOT applied.

## 4. DoctorCard Overhaul (Spotify/Duolingo)

Changes are confined to `doctor_card.dart` (no behavior change except `compact` flag):

- **Visual anchor:** `CircleAvatar(radius: 32)` (was 28). Keep existing `Hero(tag: 'doctor-avatar-${doctor.id}')` for the feed→detail shared-element transition (D4).
- **Typography (Duolingo bold hierarchy):**
  - Name `Text`: 16px **w600** #0F172A (`GoogleFonts.inter`), `maxLines: 1`, ellipsis. (Already w600 — keep.)
  - Specialty `Text`: 13px w400 #64748B. (Already 13px / #64748B — keep.)
- **"Available Today" micro-badge (new):** Insert after specialty line, before the trailing Column. Content: `Row(children: [CircleAvatar(radius: 4, color: #10B981), SizedBox(width: 4), Text('Available Today', style: Inter(12px / w500 / #10B981))])` gated by `doctor.isAvailableToday` (helper on model).
- **Heart icon:** Replace raw `IconButton(visualDensity: compact)` with a 48×48 guaranteed target:
  - ` SizedBox( width: 48, height: 48, child: IconButton( padding: EdgeInsets.zero, icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? #EF4444 : #94A3B8), onPressed: …) )`
- **Trailing column** (rating ★ + distance km): keep existing. If badge added, shift this column down by `SizedBox(height: 4)` to vertically align with the name column.
- **`compact` variant:** when `compact == true` (carousel use), set `padding: EdgeInsets.all(8)`, avatar `radius: 24`, name `14px w600`, drop the distance/Km line, keep heart + badge. Single-line name only.

## 5. Layout Shift → CustomScrollView (Slivers)

Replace `Scaffold(body: asyncDoctors.when(...Column+Expanded...))` with a `CustomScrollView`. The state branches stay, but each renders slivers:

- **Loading:** `SliverToBoxAdapter(child: Center(CircularProgressIndicator()))`.
- **Error:** `SliverToBoxAdapter(child: EmptyState(...))` (keep current widget, wrapped in `SliverToBoxAdapter`).
- **Data:**
  1. `SliverToBoxAdapter` → header Z-pattern (section 1).
  2. `SliverToBoxAdapter` → floating search bar (section 2).
  3. `SliverPersistentHeader` (pinned) → SpecialtyChip delegate (section 3).
  4. `SliverToBoxAdapter` → "Top Rated" carousel heading + carousel (section 5b).
  5. `SliverToBoxAdapter` → small gap (8px).
  6. `SliverLayoutBuilder` → branch:
     - **Width < 600 (mobile):** `SliverList.separated` of `DoctorCard` (divisor = `SizedBox(height: 8)`), item padding `EdgeInsets.symmetric(horizontal: 16, vertical: 4)`.
     - **Width ≥ 600 (web/tablet):** `SliverGrid` with `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.6)`, item padding `EdgeInsets.all(8)`.
  - **Empty:** when `filtered.isEmpty`, replace step 6 entirely with a single `SliverToBoxAdapter` showing `EmptyState` — keep current content (Icons / message), but center within scroll.

### 5b. "Top Rated" carousel

- Heading: `SliverToBoxAdapter` child = `Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text('Top Rated', style: Inter(18px / w700 / #0F172A)))`.
- Carousel: `SliverToBoxAdapter` child = `SizedBox(height: 160, child: ListView.separated(scrollDirection: Axis.horizontal, padding: EdgeInsets.only(left: 20, right: 20, bottom: 8), itemCount: topRated.length, separatorBuilder: (_,__) => SizedBox(width: 12), physics: BouncingScrollPhysics, itemBuilder: (_, i) => SizedBox(width: 240, child: DoctorCard(doctor: topRated[i], compact: true))))`.
- Data: `ref.watch(topRatedDoctorsProvider)` — watch this provider so it updates when `doctorListProvider` loads/refreshes.
- Web note: carousel stays horizontal even on wide Web (matches Spotify "row rail"). The main list below still goes responsive (grid). Document this intentionally — don't force the carousel into a grid.

## 6. Constraints (preserved, not touched)

The plan must NOT alter these (D4 explicitly preserves state wiring):
- `filteredDoctorsProvider` (`doctor_provider.dart:64`) — unchanged.
- `searchQueryProvider` (`doctor_provider.dart:58`) — unchanged; only its consumed rendering moves into `CustomScrollView`.
- `nearbyResultsProvider` / `supabaseClientProvider` / `_handleNearMe` Supabase RPC `nearby_doctors` block (`home_screen.dart:28–116`) — untouched.
- Provider wiring: `providerScope` is assumed at app root (already present via `MainApp`).

## Verification items (V)

- **V1:** After moving search into a `SliverToBoxAdapter`, confirm `_searchController` lifecycle and `onChanged` still write to `searchQueryProvider.notifier`. (Logic unchanged.)
- **V2:** Confirm live/mock `Doctor.availability` String values. If Supabase rows use tokens other than "today" (e.g., `"available"`, `"24/7"`, `"open"`), extend `isAvailableToday` helper accordingly. Fallback: show no badge (never crash).
- **V3:** Confirm Hero tag `'doctor-avatar-${doctor.id}'` still resolves on `/doctor/:id` detail screen (`doctor_details_screen.dart` should match — no change requested but must remain consistent).
- **V4:** Confirm `topRatedDoctorsProvider` is declared in `doctor_provider.dart` (new export) and imported by `home_screen.dart`.

## 7. Acceptance Criteria (visual review)

1. **Mobile (< 600px):** header greeting+title+icon, floating search, pinned chip bar, 160px Top Rated carousel (horizontal scroll), then vertical doctor list. Chips remain pinned while scrolling list.
2. **Web (≥ 1200px):** same header/search/chips/carousel; list renders as fluid `SliverGrid` (columns clamp at ~320px each, gap 12). Page background is #F5F5F5; each card is white floating.
3. **Tap targets:** heart icon and Near Me icon each render a 48×48 hit area (verified with Flutter DevTools hit-test overlay).
4. **Badge:** "Available Today" shows only when `availability` contains "today"; green dot (#10B981) + 12px text; never overlaps trailing rating.
5. **Scroll:** `CustomScrollView` scrolls as a single smooth viewport (no nested-scroll warnings). Chips pin; carousel is independent horizontal scroll.
6. **No console errors** on `flutter run -d chrome`; `flutter analyze` clean (no new lint issues introduced — D7 ensures no new nullable/field access).
7. **State integrity:** filtering by search or chip and "Near Me" (RPC) still behave identically to current behavior — only visual rendering and layout change.
