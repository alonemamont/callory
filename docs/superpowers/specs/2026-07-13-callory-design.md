# Callory — Design Spec

Date: 2026-07-13

## Overview

Callory is a Flutter mobile app (Android + iOS) for tracking daily calorie and macronutrient (protein/fat/carbs) intake. Offline-first: no backend, no user accounts, no cloud sync. Barcode/name lookup sends a query to Open Food Facts over HTTP when connectivity is available; the private food database and all diary functionality work fully offline regardless of network state. MVP scope only: calories + protein/fat/carbs — no other nutrients, no weight tracking, no water tracking.

> **Revision note (2026-07-14):** this spec was updated after an independent review (`docs/superpowers/specs/2026-07-14-callory-spec-review.md`) found several ambiguities that would block deterministic implementation and testing. Every section below reflects the resolved decisions; see the "Domain rules and constraints" section for the consolidated list of what changed and why.

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
  meal_id (fk → Meal, ON DELETE: not applicable — meals are never deleted while non-empty; see below)
  private_food_id (fk → PrivateFood, nullable, ON DELETE SET NULL)
  food_name_snapshot          // required, non-empty
  grams                        // required, > 0
  kcal_snapshot, protein_snapshot, fat_snapshot, carbs_snapshot   // required, >= 0
  occurred_at   // editable time of consumption; drives diary display and meal grouping
  created_at    // immutable real timestamp of the add action
  updated_at    // real timestamp of the most recent edit action (nullable until first edit)
  entry_date    // the diary date this entry belongs to (may differ from occurred_at's date, e.g. logging yesterday's dinner after midnight)

Meal
  id (pk)
  day_date
  meal_number (1, 2, 3, ...)  // a display label, not a stable sort key or identity — see numbering rules below
  is_manual (bool)  // true once user manually moves/splits/merges into or out of this meal; auto-regrouping never touches a manual meal

Goals
  daily_kcal, daily_protein, daily_fat, daily_carbs
  mode: enum(calculated, manual)
  // calculated mode also stores: age, weight, height, sex, activity_level, goal_type (for recompute)
  // single global row — see "Goals history" below for the historical-accuracy trade-off this makes
```

### Nutrition snapshotting

`DiaryEntry` stores its own computed kcal/protein/fat/carbs at the time of logging (`*_snapshot` fields), not just a foreign key to `PrivateFood`. This is deliberate: editing or deleting a `PrivateFood` row (which the copy-and-edit flow actively encourages) must never retroactively change historical log entries. `private_food_id` is nullable so deleting a private food doesn't break past entries — the snapshot is independent and permanent.

### Editing a logged entry

After logging, the user may edit two fields on a `DiaryEntry`: `grams` and `occurred_at`. Editing the food itself is a separate flow (editing `PrivateFood`) and never touches past entries. Editing either field sets `updated_at` to the current real time; `created_at` never changes after insert.

- **Editing `grams`**: reject values <= 0. Recompute `*_snapshot` values by scaling the entry's own originally-recorded per-100g ratio (`kcal_snapshot / grams_old * 100`, etc.) — not by re-fetching current `PrivateFood` values, which may have since changed. This preserves snapshot consistency.
- **Editing `occurred_at`**: may move the entry into a different cluster. Re-run auto-grouping (see below) for the affected `entry_date` unconditionally — this is always safe and correct, including when the new time is earlier than other entries already logged that day.
- **Deleting an entry**: remove the row, then re-run auto-grouping for the affected `entry_date`. Any meal — manual or auto — left with zero entries afterward is deleted.

### Meal grouping algorithm

`occurred_at` is always the user-facing, editable time of consumption — never a synthetic "noon of day" value — even when the user is backdating food to a past day's log. `created_at`/`updated_at` are separate, non-editable audit timestamps and play no part in grouping.

Grouping only ever affects the **auto partition**: entries whose current `meal_id` points to a `Meal` with `is_manual = false`. Entries in a manual meal are never moved, re-clustered, or renumbered by auto-grouping, and a manual meal's `meal_number` never changes once created.

Every operation that can affect grouping (add entry, edit `occurred_at`, delete entry, or any manual move/split/merge) re-runs the **same deterministic full regroup** over the auto partition for that `entry_date`, rather than an incremental "compare only to the last meal" step — this is the one algorithm, always:

1. Collect all `DiaryEntry` rows for the `entry_date` whose current meal is non-manual. Sort them by `occurred_at` ascending, tie-broken by `id` ascending.
2. Let `next_number = (max meal_number among manual meals for this entry_date, default 0) + 1`.
3. Walk the sorted list, tracking the `occurred_at` of the previous entry **in the current cluster**: start a new cluster (new auto `Meal`, `meal_number = next_number`, then increment `next_number`) whenever this is the first entry, or `occurred_at - <previous cluster entry's occurred_at> > gap_window`. Otherwise append to the current cluster's meal.
4. Because manually-assigned entries are excluded from the sorted list entirely in step 1, a manual meal interleaved chronologically between two auto entries does not break the auto run — the gap is always measured against the nearest preceding *auto* entry, never a manual one. This is the deliberate answer to "entries that bridge or overlap manually corrected meals."
5. Delete any old auto `Meal` row for that `entry_date` that ends up with zero entries after reassignment. (Manual meals emptied by a delete/move are also deleted — see "Manual meal invariants" below.)

Auto `meal_number` values are therefore **not stable across regroups** — they are a display label recomputed each pass, not an identity. UI code must key widgets/list state on `Meal.id`, never on `meal_number`. Manual `meal_number` values, once assigned, are permanent.

**Display ordering:** because manual meal numbers can be non-contiguous or out of chronological order relative to auto meals (e.g. a manual meal created with `meal_number = 5` earlier in the day than auto meal `1`), the day view sorts meals for display by the earliest `occurred_at` among their entries, not by `meal_number`.

### Manual meal invariants

- **Move** (reassign one entry to a different existing meal): the destination meal becomes `is_manual = true` (even if it was previously an auto meal — touching it via a manual action locks it). The source meal is left as-is if non-empty; if the move empties it, it is deleted regardless of its own manual/auto status.
- **Split** (move a subset of a meal's entries out into a new meal): the new meal is created with `is_manual = true`. The source meal's `is_manual` flag is also set to `true` if it wasn't already — a meal that has been split is considered manually curated even for the entries left behind, so a later auto-regroup pass never re-merges them.
- **Merge** (combine two meals into one): the result keeps the target meal's `id` and `meal_number`, is set `is_manual = true`, and the other meal is deleted after its entries are reassigned.
- A brand-new entry (via barcode/search/manual add) is always assigned by the auto-grouping algorithm above; it can only end up in a manual meal through an explicit subsequent **move** by the user. Auto-grouping never assigns a new entry directly into a manual meal, even if its `occurred_at` would fall within `gap_window` of that meal.
- There is no separate per-entry lock — an entry's "manual" status is entirely inherited from whether its current `meal_id` points to a manual meal. This is a deliberate simplification (rejecting finer-grained per-entry locking) since MVP has no UI need for it.
- Invariant enforced at the repository layer (not a DB constraint): a `DiaryEntry.meal_id` must always reference a `Meal` whose `day_date` equals the entry's own `entry_date`. No operation may assign an entry to a meal belonging to a different day.

## Domain rules and constraints

- **`gap_window` setting**: persisted locally (not in the SQLite DB — a device setting), integer minutes, default 90, adjustable range 15–240 via a slider in Settings. Changing it takes effect only for future auto-grouping decisions (new adds, edits, deletes) — it never triggers a retroactive regroup of existing history on its own.
- **Numeric types and validation**: `grams` and all per-100g/snapshot nutrient fields are stored as real numbers. `grams` must be `> 0` (rejected otherwise, both in the UI and at the repository layer); nutrient fields must be `>= 0`; `name` (on `PrivateFood`) is required and non-empty after trimming. No upper-bound validation on values — trusted user input, not a public form. Values are stored at full precision; rounding to the nearest integer happens only at display time in the UI.
- **Barcode uniqueness**: not enforced. A user can scan the same product twice and get two separate `PrivateFood` rows; `findByBarcode` returns the first match. This is a deliberate simplification — no dedup/merge UX is built for MVP.
- **Foreign-key deletion behavior**: deleting a `PrivateFood` sets `DiaryEntry.private_food_id` to `NULL` on any referencing rows (`ON DELETE SET NULL`); the entry's `*_snapshot` values are untouched. There is no manual "delete meal" action in the UI — `Meal` rows are only ever removed automatically by the grouping algorithm when they become empty, so no separate meal-deletion FK policy is needed.
- **Day/entry-date consistency invariant**: enforced at the repository layer (not expressible as a simple SQL constraint) — a `DiaryEntry.meal_id` must always reference a `Meal` whose `day_date` equals the entry's own `entry_date`. No repository operation may violate this.
- **`entry_date` derivation**: defaults to the local calendar date of `occurred_at` at the moment the entry is created, using the device's local timezone at that instant. The user may override `entry_date` explicitly when backdating (e.g. logging a post-midnight snack as "yesterday"). Once set, `entry_date` is not recomputed if the device's timezone later changes — it's a resolved, immutable value unless the user explicitly edits it.
- **Meal numbering stability**: manual `meal_number` values are fixed at creation and permanent. Auto `meal_number` values are recomputed on every regroup pass as sequential integers starting after the current max manual number for that day, and are **not** stable across regroups — they're a display label, not an identity. A day that isn't touched again is never renumbered; only editing/adding/deleting within that specific day triggers its regroup.

## Food sources

```dart
abstract class FoodSource {
  Future<List<FoodResult>> searchByName(String query);
  Future<FoodResult?> lookupBarcode(String barcode);
}
```

**`FoodResult` contract**: `name` (String, required — falls back to `"Unknown"` if the source's own label is blank), `barcode` (String?, optional), `kcalPer100g`/`proteinPer100g`/`fatPer100g`/`carbsPer100g` (double, required, `>= 0` — all four are mandatory, no partial-nutrition results), `existingPrivateFoodId` (int?, set when the result already exists in the user's private food database, letting the UI skip the "copy to private db" step). Mapping from Open Food Facts: `energy-kcal_100g` / `proteins_100g` / `fat_100g` / `carbohydrates_100g`. If any of the four required nutrient fields is missing or non-numeric in the source data, the product is excluded from results entirely — never shown with a zero/partial value standing in for missing data.

**Result ordering**: `searchByName` on the combined lookup returns the private database's matches first (its own order: alphabetical by name), followed by the external source's matches in whatever order it returns them. There is no cross-source de-duplication in MVP, even when a barcode matches both a private and an external result — a deliberate simplification, not a gap.

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

**Diary-entry flow, resolved**:
- A `PrivateFood` row is always created (or reused, via `existingPrivateFoodId`) before its `DiaryEntry` — there is no diary entry without a backing food row.
- The editable card always prefills `grams = 100`.
- Saving the food and logging the diary entry happen as **one atomic user action**: the `PrivateFood` insert and the `DiaryEntry` insert both happen only after the user taps Save on the same dialog. There is no intermediate state where a food is saved but not yet logged, so "cancel after saving but before logging" cannot occur in MVP.
- Editing or deleting a `PrivateFood` afterward never touches existing `DiaryEntry` rows — snapshot independence (see "Nutrition snapshotting" above) and the `ON DELETE SET NULL` behavior (see "Domain rules and constraints") both apply regardless of when the edit/delete happens.

## Goals and BMR/TDEE calculation

Two modes, toggled in settings:

- **Manual**: user directly enters daily_kcal + protein/fat/carbs in grams.
- **Calculated**: user provides sex, age, weight, height, activity level (sedentary/light/moderate/high), and goal type (lose/maintain/gain). Exact formula, locked for MVP (no alternatives):
  - BMR (Mifflin-St Jeor): male = `10*weightKg + 6.25*heightCm - 5*age + 5`; female = `10*weightKg + 6.25*heightCm - 5*age - 161`.
  - TDEE = `BMR * activityMultiplier`, where sedentary = 1.2, light = 1.375, moderate = 1.55, high = 1.725.
  - Goal-adjusted kcal = `TDEE * (1 + goalAdjustment)`, where lose = -0.20, maintain = 0.0, gain = +0.15.
  - Macros: percentage-of-kcal split only (the grams-per-kg-bodyweight alternative is explicitly not built for MVP) — protein 30% / fat 30% / carbs 40% of the goal-adjusted kcal, converted via protein 4 kcal/g, fat 9 kcal/g, carbs 4 kcal/g.
  - All intermediate and stored values are doubles at full precision; rounding to the nearest integer happens only at display time.
  - The result can be manually overridden afterward (switches the record to manual mode). This override **discards** the stored profile inputs (age/weight/height/sex/activity level/goal type) rather than retaining them as a restorable "calculated baseline" — a deliberate MVP simplification. To get calculated numbers again, the user re-enters their profile from scratch.

The day view shows actual (sum of all entries for the day) vs. goal, as a progress indicator for each of the four values.

**Goals history**: the `Goals` table holds exactly one current global record (saving new goals replaces it, it is not versioned). The day view for **any** date — past or present — always displays the *current* goal, not a historical snapshot of what was active on that date. This is a known MVP limitation, not an oversight; per-day goal history is out of scope for now.

## Export / Import

- **Export**: dump all Drift tables (`PrivateFood`, `DiaryEntry`, `Meal`, `Goals`) into a single JSON file; user saves it via the system share/file picker.
- **Import**: user picks a file → parse → validate schema (file includes a format version) → **full replacement** of the local database (no merge) → user must confirm a warning that current data will be overwritten.
- **JSON envelope**: `{ formatVersion: int, privateFoods: [...], meals: [...], diaryEntries: [...], goals: [...] }` — one array per table, each row serialized via Drift's generated `toJson()`/`fromJson()` (camelCase Dart column names; `DateTime` fields as ISO-8601 strings, Drift's default). `id` (autoincrement PK) values are included as-is and reinserted unchanged on import — not regenerated — since import always targets a freshly wiped database within the same transaction, so existing internal FK references (`mealId`, `privateFoodId`) survive the round trip without an id-remapping pass.
- **Version policy**: MVP supports exactly `formatVersion == 1`. Any other value (including missing) is rejected immediately with a `FormatException` naming the unsupported version, before any data is touched. No migration logic exists yet — there is only one version.
- **Atomicity guarantee**: the format-version check happens before any database mutation. The delete-existing-tables + insert-all-rows sequence runs inside a single Drift transaction; any failure partway through (malformed row, a foreign-key violation such as a `diaryEntries` row referencing a `mealId` absent from the `meals` array) throws, and Drift rolls the transaction back automatically — the existing database is left unchanged. This satisfies the "parse and validate, then atomically replace, or leave untouched on any failure" requirement without needing a separate two-pass validate-then-commit step.
- **Error messages**: unreadable/malformed JSON → "Invalid file — could not read JSON"; unsupported `formatVersion` → the `FormatException` message verbatim; a referentially-invalid row rejected mid-transaction → "Import failed — file has inconsistent data" (database confirmed unchanged, per the atomicity guarantee above).

## Testing

- **Unit tests**: gap-based meal grouping logic (boundary cases: exactly at the gap threshold, manual-lock skipping regrouping, insertion in the middle of an existing day, backdating an entry earlier than others already logged that day), BMR/TDEE formula, grams-edit snapshot rescaling.
- **Repository tests**: in-memory SQLite (Drift) for CRUD operations and JSON export/import roundtrip.
- **Widget tests**: day view screen (meal list, goal progress indicators).
- **FoodSource tests**: mocked HTTP for `OpenFoodFactsSource`; no real network calls in the test suite.
- **Additional coverage added after spec review** (`2026-07-14-callory-spec-review.md`):
  - Adding entries to past days, and editing an entry's `occurred_at` to a time earlier than other entries already logged that day.
  - Inserting an entry chronologically between two existing auto entries; deleting entries, including cases that empty an auto meal or a manual meal (both must be removed).
  - The full move/split/merge state-transition matrix (touched meals become manual; empty source meals are removed regardless of prior manual/auto status), followed by an auto-regroup pass to confirm manual meals are untouched.
  - Deleting a `PrivateFood` referenced by existing `DiaryEntry` rows: `private_food_id` becomes `NULL`, snapshot values are preserved exactly.
  - Nutrition rounding and daily totals (sum of snapshots matches the rounded value shown in the UI).
  - Malformed JSON, an unsupported/missing `formatVersion`, and a referentially-invalid row (e.g. a `diaryEntries` row pointing at a nonexistent `mealId`) — all three must leave the existing database unchanged.
  - Network timeout/offline and Open Food Facts responses with missing nutriment data — confirming graceful degradation (empty result / excluded product), never a crash.
