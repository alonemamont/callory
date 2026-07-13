# Callory — review of the design spec

Reviewed document: `2026-07-13-callory-design.md`  
Review date: 2026-07-14

## Overall assessment

The foundation is strong: the MVP boundaries are clear, the architecture is reasonable, and nutrition snapshots protect diary history from changes to foods. However, the specification is not yet fully internally consistent or sufficient for unambiguous implementation. The main risks are time semantics, meal grouping, and goal calculations.

## Critical inconsistencies

### `logged_at` has contradictory semantics

The field is described both as the real time at which an entry is added or edited and as a user-editable field used for meal grouping. When a user adds yesterday's dinner today, the real action time cannot represent the dinner's time. Therefore it cannot correctly support historical diary entries or grouping.

Define at least two fields:

- `occurred_at`: the editable time of consumption; it is used for diary display and meal grouping.
- `created_at` and, if needed, `updated_at`: actual timestamps of the create/edit operations.

References: design spec lines 63–64 and 84–98.

### The meal grouping algorithm is incomplete

The algorithm does not define how to handle:

- adding an entry in the middle of a day;
- editing an entry to an earlier time;
- deleting an entry;
- entries that bridge or overlap manually corrected meals;
- an empty meal after moving or deleting its final entry.

"Last non-manual Meal" is ambiguous: last by meal number, chronological time, or creation time? For an entry whose time is earlier than the selected meal, the stated subtraction is negative and will incorrectly satisfy `<= gap_window`.

Specify a deterministic regrouping algorithm over entries sorted by `occurred_at` and tie-breakers. State explicitly which entries and meals are immutable after manual operations, and what happens in automatic segments around them.

References: design spec lines 91–96.

### Manual meal locks are underspecified

The requirement that manual corrections must not be overwritten does not define the state transitions for move, split, and merge operations:

- Which meals become manual: source, destination, both, or a newly created meal?
- How are empty meals handled?
- Can a new automatic entry join a manual meal?
- What happens if automatic regrouping would merge or split entries adjacent to a manual meal?

An `is_manual` flag on a meal may not be sufficient to express manual boundaries. Define the invariants, or use an explicit representation of locked boundaries / manually assigned entries.

### BMR/TDEE calculation leaves product decisions open

The spec gives alternatives as examples instead of choosing one algorithm: activity coefficients, lose/gain adjustments, and macro split are not fixed. "Percentage split or grams per kilogram" is a mutually exclusive choice.

Choose and document exact constants, calculation order, units, rounding, supported sex values, and one macro method. Otherwise the calculation and its tests cannot be deterministic.

Reference: design spec line 130.

### "Fully offline" conflicts with HTTP food lookup

The app uses HTTP requests to Open Food Facts, so it is not fully offline. The intended claim appears to be "offline-first, with no own backend or accounts." Use that wording and explain that barcode/name lookup sends the relevant query to the external provider when connectivity is available.

References: design spec lines 7, 25, and 109–123.

## Missing domain rules and storage constraints

- Add a persisted setting for `gap_window`: default, units, allowed range, UI, and whether changing it regroups existing history.
- Define numeric types and rounding for grams and nutrition; validate positive grams, non-negative nutrients, required names, and value limits.
- Define barcode uniqueness and duplicate-food policy.
- Specify foreign-key deletion actions. In particular, deleting a food should set `DiaryEntry.private_food_id` to `NULL`, while preserving snapshots. Define the behaviour of meal deletion and prevent an entry from referencing a meal of another `entry_date`.
- Decide whether `entry_date` is user-selected or derived from `occurred_at` in the local time zone. Define day boundaries and time-zone change behaviour.
- Define ordering and numbering of meals after split, merge, move, and deletion. Clarify whether numbering is always contiguous and whether historical meals are renumbered.

## Food-source and add-flow ambiguities

`FoodResult` has no contract. Specify required and optional fields, units, mapping from Open Food Facts, handling of missing nutrition values, and display labels/source metadata.

"Local priority" and "merged result list" do not define result ordering or duplicate removal. State whether local exact matches appear first, how barcode/name duplicates are identified, and whether external results are shown after a network failure.

Also specify the diary-entry flow:

- Is a private food always created before a diary entry?
- What grams value is prefilled?
- What happens if the user cancels after saving a food but before logging it?
- Can a product be edited or deleted while its historical entries remain intact?

References: design spec lines 102–123.

## Goals and history

The `Goals` table appears to store one current global goal. The spec must decide whether a past day displays the goal that was active on that date or the current goal. Historical accuracy requires versioned goals or a per-day snapshot.

Clarify the transition from calculated to manual mode: whether calculated inputs are retained, whether a user can edit only one resulting macro, and how the calculated baseline is restored.

## Import/export requirements

Import should be atomic:

1. Parse and validate the complete file, including its format version, types, constraints, and foreign-key relationships.
2. Only then replace the local data in one transaction.
3. On any failure, retain the existing database unchanged.

Also define the JSON envelope, version migration policy, identifier handling, date/time serialization, and error messages for invalid or incompatible files.

References: design spec lines 136–137.

## Test coverage to add

The planned test categories are appropriate but should additionally cover:

- adding entries to past days and editing consumption time;
- inserting an entry between two existing entries, deleting entries, and removing empty meals;
- all move/split/merge cases followed by automatic grouping;
- storage constraints and food deletion with preserved snapshots;
- nutrition rounding and daily totals;
- malformed, old, new, and referentially invalid JSON, including atomic import failure;
- network timeout/offline and incomplete Open Food Facts responses.

References: design spec lines 139–144.

## Recommended next step

Before implementation, create a focused domain-rules specification for `DiaryEntry`, `Meal`, and `Goals`. It should define time fields, grouping invariants, all manual-operation transitions, numeric precision, and exact TDEE/macro constants. Those decisions remove the current blockers and make repository and unit-test acceptance criteria concrete.
