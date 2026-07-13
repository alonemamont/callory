# Callory — Design Spec

Date: 2026-07-13

## Overview

Callory is a Flutter mobile app (Android + iOS) for tracking daily calorie and macronutrient (protein/fat/carbs) intake. Fully offline, no backend, no user accounts. MVP scope only: calories + protein/fat/carbs — no other nutrients, no weight tracking, no water tracking.

## Core features

- Log food entries with gram-based quantities (no other portion units in MVP).
- Three ways to populate a private food database:
  1. Barcode scan → lookup against an external database → editable before saving.
  2. Manual entry → user fills in all fields.
  3. Copy from external search result → editable before saving.
- All added foods live in a private, per-device food database. No shared/public database is written to.
- Entries are automatically grouped into numbered meals ("Прием 1", "Прием 2", ...) based on a time gap since the previous entry that day. Users can manually correct grouping (move/split/merge); manual corrections are not overwritten by auto-grouping.
- Daily goals for kcal/protein/fat/carbs, either manually entered or calculated from user profile (BMR/TDEE), editable either way.
- View today's log and navigate back to previous days (read/edit history), no charts/graphs in MVP.
- JSON export of all local data; JSON import fully replaces local data (no merge).
- Free app, no monetization.

## Architecture

Fully offline, no backend.

```
UI (Widgets)
  ↓
Riverpod Providers (state)
  ↓
Repositories (DiaryRepo, FoodRepo, GoalsRepo)
  ↓
Drift (SQLite) — local storage
  ↓
FoodSource interface → OpenFoodFactsSource (HTTP) | PrivateFoodRepo (local)
```

UI never touches Drift directly — only through repositories. Repositories are the only layer aware of SQL/HTTP details. This keeps UI testable (mock repositories) and leaves room to add a cloud backend later without UI changes.

**Storage engine: Drift (SQLite).** Chosen over Isar because the data is inherently relational (food ↔ entry ↔ meal ↔ day joins, date-range queries for history navigation), and Drift's schema migrations and SQL querying fit that shape naturally. Isar would require emulating joins manually.

**State management: Riverpod.** No alternatives considered — defensible default for this scope.

## Data model (Drift tables)

```
PrivateFood
  id (pk)
  name
  barcode (nullable)
  kcal_per_100g, protein_per_100g, fat_per_100g, carbs_per_100g
  source: enum(barcode, manual, copied_external)
  created_at

DiaryEntry
  id (pk)
  meal_id (fk → Meal)
  private_food_id (fk → PrivateFood, nullable)
  food_name_snapshot
  grams
  kcal_snapshot, protein_snapshot, fat_snapshot, carbs_snapshot
  logged_at   // real timestamp of when the entry was added/edited
  entry_date  // the diary date this entry belongs to (may differ from logged_at's date, e.g. logging yesterday's dinner after midnight)

Meal
  id (pk)
  day_date
  meal_number (1, 2, 3, ...)
  is_manual (bool)  // true once user manually moves/splits/merges; auto-regrouping skips manual meals

Goals
  daily_kcal, daily_protein, daily_fat, daily_carbs
  mode: enum(calculated, manual)
  // calculated mode also stores: age, weight, height, sex, activity_level, goal_type (for recompute)
```

### Nutrition snapshotting

`DiaryEntry` stores its own computed kcal/protein/fat/carbs at the time of logging (`*_snapshot` fields), not just a foreign key to `PrivateFood`. This is deliberate: editing or deleting a `PrivateFood` row (which the copy-and-edit flow actively encourages) must never retroactively change historical log entries. `private_food_id` is nullable so deleting a private food doesn't break past entries — the snapshot is independent and permanent.

### Editing a logged entry

After logging, the user may edit two fields on a `DiaryEntry`: `grams` and `logged_at`. Editing the food itself is a separate flow (editing `PrivateFood`) and never touches past entries.

- **Editing `grams`**: recompute `*_snapshot` values by scaling the entry's own originally-recorded per-100g ratio (`kcal_snapshot / grams_old * 100`, etc.) — not by re-fetching current `PrivateFood` values, which may have since changed. This preserves snapshot consistency.
- **Editing `logged_at`**: may move the entry outside its current meal's time gap. Re-run auto-grouping for the affected day, skipping any `Meal` rows with `is_manual = true`.

### Meal grouping algorithm

Rolling-gap grouping, evaluated against `logged_at` within a single `entry_date`:

1. On adding an entry, find the last non-manual `Meal` for that `entry_date`.
2. If `logged_at - <last entry's logged_at in that meal> <= gap_window` (gap_window is user-configurable), assign to that meal.
3. Otherwise, create a new `Meal` with `meal_number` incremented.
4. If the user manually reassigns/splits/merges meals, the affected `Meal` row(s) get `is_manual = true` and are excluded from future auto-regrouping passes.

`logged_at` is always the real timestamp of the add/edit action (not noon-of-day or any synthetic time), even when the user is adding food to a past day's log.

## Food sources

```dart
abstract class FoodSource {
  Future<List<FoodResult>> searchByName(String query);
  Future<FoodResult?> lookupBarcode(String barcode);
}
```

Two implementations for MVP:
- `OpenFoodFactsSource` — HTTP, no API key required.
- `PrivateFoodRepo` — the user's local food database, always available offline, searched with priority over the external source.

**FatSecret explicitly excluded from MVP.** Its Platform API requires a client secret; with no backend to hold it, the secret would ship inside the app binary and be trivially extractable. The `FoodSource` interface is designed to allow slotting in a paid/keyed source later once a backend or proxy exists, but nothing beyond Open Food Facts is built now.

Research into Russian/CIS product coverage confirmed there's no ready-made source with good branded-product coverage for the Russian market — Open Food Facts's Russian coverage is thin, FatSecret's Russian dataset inclusion is unconfirmed, and government/scientific databases (ФИЦ питания) only cover generic (non-branded) foods with no public API yet. The user's private food database is the actual mechanism that closes this gap, by design.

### Add-food flows

1. **Barcode scan** → `OpenFoodFactsSource.lookupBarcode()` → if found, pre-filled editable card → save to `PrivateFood` (source=barcode). If not found, fall through to manual entry.
2. **Search by name** → query `PrivateFoodRepo` (priority) and `OpenFoodFactsSource` in parallel → merged result list → selecting an external result copies it into an editable card → save to `PrivateFood` (source=copied_external).
3. **Manual entry** → blank form, user fills every field → save to `PrivateFood` (source=manual).

**Error handling**: if there's no network or Open Food Facts is unreachable, external search/barcode lookup degrades to an empty result with a "no connection" message. The private food database always works offline-first regardless of network state.

## Goals and BMR/TDEE calculation

Two modes, toggled in settings:

- **Manual**: user directly enters daily_kcal + protein/fat/carbs in grams.
- **Calculated**: user provides sex, age, weight, height, activity level (sedentary/light/moderate/high), and goal type (lose/maintain/gain). Mifflin-St Jeor formula computes BMR → multiplied by an activity coefficient for TDEE → adjusted by goal type (e.g. -20%/+15%) → macros split by a standard ratio (e.g. protein 30% / fat 30% / carbs 40%, or grams-per-kg-bodyweight based). The result can be manually overridden afterward (switches the record to manual mode over the calculated baseline).

The day view shows actual (sum of all entries for the day) vs. goal, as a progress indicator for each of the four values.

## Export / Import

- **Export**: dump all Drift tables (`PrivateFood`, `DiaryEntry`, `Meal`, `Goals`) into a single JSON file; user saves it via the system share/file picker.
- **Import**: user picks a file → parse → validate schema (file includes a format version) → **full replacement** of the local database (no merge) → user must confirm a warning that current data will be overwritten.

## Testing

- **Unit tests**: gap-based meal grouping logic (boundary cases: exactly at the gap threshold, manual-lock skipping regrouping), BMR/TDEE formula, grams-edit snapshot rescaling.
- **Repository tests**: in-memory SQLite (Drift) for CRUD operations and JSON export/import roundtrip.
- **Widget tests**: day view screen (meal list, goal progress indicators).
- **FoodSource tests**: mocked HTTP for `OpenFoodFactsSource`; no real network calls in the test suite.
