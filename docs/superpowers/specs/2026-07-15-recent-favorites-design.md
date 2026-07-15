# Callory - Recent And Favorites Design

Date: 2026-07-15

## Overview

This spec adds a new `Recent` entry point to the existing `Add food` flow and introduces a persistent favorites flag for local foods.

The feature goals are:

- Make commonly reused foods reachable without typing a search query.
- Let the user mark foods as favorites and quickly filter to only those favorites.
- Keep the current local-first architecture and avoid adding new top-level entities unless they are required.

This spec does not change daily diary calculations, meal grouping, goals, or the external food source contract.

## Current context

The current `Add food` screen has three tabs:

1. `Search`
2. `Barcode`
3. `Manual`

Local products are stored in `PrivateFoods`. Diary usage is stored in `DiaryEntries`. Search and barcode lookup already prioritize local foods through `FoodLookupService` and `FoodRepository`.

There is currently no favorites concept in the schema, repository layer, export/import flow, or UI.

## User-approved decisions

- The new screen opens on `Recent`.
- `Recent` is a single list, not separate blocks or nested tabs.
- `Recent` shows unique local products sorted by most recent diary usage.
- A filter `Only favorites` sits above the list.
- Favorite actions are available everywhere a product is shown.
- If the user favorites an external search result, the app immediately creates a local product and marks it favorite without opening the edit dialog.
- Favorites are exported and imported together with `PrivateFoods`.

## Data model changes

### PrivateFoods

Add:

- `isFavorite` (`bool`, required, default `false`)

Resulting logical shape:

```text
PrivateFood
  id
  name
  barcode?
  kcalPer100g
  proteinPer100g
  fatPer100g
  carbsPer100g
  source
  isFavorite
  createdAt
```

### No new favorites table

Favorites are a property of a local product, not a separate entity. A separate `FavoriteFoods` table is intentionally rejected because it adds joins and migration complexity without enabling a user-visible capability needed for this scope.

## Definition of "Recent"

`Recent` is derived from diary usage, not from product creation time.

Rules:

- Only local products are eligible.
- A product appears at most once in the list.
- Ordering is by latest usage descending, using `max(DiaryEntries.occurredAt)` for each `privateFoodId`.
- Products with no diary usage do not appear in `Recent`, even if they are favorites.
- Diary rows with `privateFoodId = null` do not contribute to `Recent`.
- If two products have the same latest usage timestamp, the query must apply a deterministic secondary ordering. Use `name ASC`, then `id DESC`.

This keeps `Recent` tied to real usage instead of technical save events.

## UI behavior

### Add food tabs

The `Add food` screen becomes:

1. `Recent`
2. `Search`
3. `Barcode`
4. `Manual`

Initial tab is always `Recent`.

### Recent tab

The tab contains:

- A top-level `Only favorites` toggle.
- A list of unique recent local foods.
- An empty state when there are no recent foods.
- A separate empty state when the list is empty only because the favorites filter is enabled.

Each row shows:

- Food name
- Nutrition summary already used in other food lists
- Favorite state

Each row supports:

- Tap row -> open the existing `Food details` dialog to log grams and optionally edit product fields according to current behavior
- Tap favorite control -> toggle favorite on/off without opening the dialog

### Search tab

Favorite action appears on every result row.

Behavior:

- Local result (`existingPrivateFoodId != null`): toggle its `isFavorite` flag directly.
- External result:
  - Create a local `PrivateFood` immediately from the external result data.
  - Mark it `isFavorite = true`.
  - Do not create a diary entry.
  - Do not open the edit dialog.

Normal tap behavior is unchanged: tapping a result still opens the existing dialog for grams/details and diary logging.

### Barcode tab

Base behavior stays the same:

- Local barcode hit -> existing local product flow.
- External barcode hit -> existing editable dialog flow.
- Not found -> existing snackbar/manual fallback.

Favorite behavior:

- If a local product is opened, the dialog can change favorite state.
- If an external barcode result is opened, the dialog can save it as favorite.

The barcode flow does not get automatic diary logging from favorite actions.

### Manual tab

Manual creation can save the product with either:

- `isFavorite = false`
- `isFavorite = true`

Creating a favorite manually still does not place it into `Recent` until the product is actually used in a diary entry.

## Repository and query design

### FoodRepository responsibilities

Extend `FoodRepository` with:

- `insertFood(..., {bool isFavorite = false})`
- `setFavorite(int id, bool value)`
- `toggleFavorite(int id)`
- `getRecentFoods({required bool favoritesOnly})`

### Recent query contract

`getRecentFoods` returns only local products that have at least one diary entry linked by `privateFoodId`.

Required behavior:

- Deduplicate by `privateFoodId`
- Compute `lastUsedAt = max(occurredAt)`
- Sort by `lastUsedAt DESC`, then `name ASC`, then `id DESC`
- When `favoritesOnly = true`, filter on `isFavorite = true`

The query returns `List<FoodResult>`. `lastUsedAt` is an internal sort key only and is not exposed to the current UI.

## Domain and duplication rules

### Favorite ownership

Only local products can persist favorite state.

An external result becomes favorite only by being converted into a local product.

### Duplication rules for favorite actions

When favoriting an external result:

- If the row already has `existingPrivateFoodId`, update that existing local product.
- If the row does not have `existingPrivateFoodId` but has a barcode, first check local storage by barcode.
- If a local barcode match exists, mark the existing local product as favorite instead of inserting a duplicate.
- If there is no barcode, do not attempt fuzzy or name-based deduplication.

Name-based silent deduplication is explicitly out of scope because it risks false matches and hidden data changes.

### Delete behavior

Deleting a local product removes it from:

- local search results
- future `Recent` results
- favorite views

Existing diary snapshots remain intact under current diary snapshot rules.

## Edit dialog behavior

The existing `Food details` dialog remains the central path for logging grams and editing food fields.

It must support favorite state for:

- local products
- manual creation
- external barcode/search paths when they go through normal save flow

Rules:

- Saving a local product through the dialog must update the existing product, not create a duplicate local row.
- Saving an external/manual product through the dialog creates one local product and one diary entry.
- Cancel does nothing.
- Favorite changes must not implicitly create diary entries.
- Changing grams affects only the diary entry being created, not the stored favorite state.

## Export and import

`isFavorite` is part of the canonical `PrivateFood` data model and must participate in JSON export/import.

Required behavior:

- Export includes `isFavorite` for every private food.
- Import restores `isFavorite` together with the rest of `PrivateFoods`.
- Import remains full-replacement, consistent with the existing app contract.

No separate migration logic is needed at import time beyond handling the new field in serialized rows.

## Error handling

- Failed local favorite toggle must leave the UI in the previous consistent state and show controlled feedback.
- Failed silent-save of an external favorite must not visually claim success.
- Empty `Recent` is not an error.
- Empty favorites-only `Recent` is not an error.
- External lookup/search failures do not change the favorites contract for already local products.

## Testing requirements

### Migration tests

- Old schema migrates to the new schema with `isFavorite` added.
- Existing products receive `isFavorite = false`.
- Existing rows in other tables survive migration unchanged.
- Reopening the database after migration remains stable.

### Repository tests

- `insertFood` defaults `isFavorite` to `false`.
- `insertFood` persists explicit `isFavorite = true`.
- `setFavorite` updates only the target row.
- `toggleFavorite` flips state in both directions.
- `updateFood` does not reset favorite state.
- `findByBarcode` returns the current favorite state.
- `searchByName` returns favorite state for local results.
- Deleting a product removes it from local lookups and future recent queries.

### Recent query tests

- `getRecentFoods` returns unique local products only.
- A product used multiple times appears once.
- Sorting uses latest `occurredAt` descending.
- Products never used in the diary do not appear.
- `privateFoodId = null` diary entries are ignored.
- `favoritesOnly = true` filters correctly.
- A favorite product with no usage still does not appear.
- Deleted products no longer appear.
- Tie-breaking is deterministic with equal timestamps.

### Lookup and duplication tests

- Local search results still appear before external results.
- Local barcode lookup still overrides external lookup.
- Local result favorite state survives lookup service composition.
- Favoriting an external result creates a local favorite product without creating a diary entry.
- If a local barcode match already exists, favoriting the external result updates the existing row instead of duplicating it.
- Barcode-less external results do not silently deduplicate by name.

### Dialog and widget tests

- Manual save can create a favorite product.
- Manual save can create a non-favorite product.
- Cancel creates nothing.
- Saving a local product via dialog does not create a duplicate local row.
- Saving an external/manual product via dialog creates one local row and one diary entry.
- Favorite state in the dialog reflects the current local state.
- Invalid numeric input handling does not break favorite behavior.

### Add food screen tests

- Initial tab is `Recent`.
- Tab order is `Recent`, `Search`, `Barcode`, `Manual`.
- Empty recent state renders correctly.
- Favorites-only empty state renders correctly.
- Favorite toggling from `Recent` updates the row immediately.
- Tapping a `Recent` row opens the existing dialog.
- After diary logging, the recent list refreshes and ordering updates if needed.

### Search tab tests

- Local results show current favorite state.
- Local result favorite toggle does not open the dialog.
- External result favorite action performs silent-save.
- Silent-save does not create a diary entry.
- After silent-save, the result is treated as local on subsequent local lookup paths.
- Silent-save failure does not show false success.

### Barcode tests

- Local barcode hit still opens the local flow.
- External barcode hit still opens the editable dialog flow.
- Not-found behavior remains intact.
- Repeated scanner detect events do not trigger duplicate dialogs or duplicate favorite writes.

### Export/import tests

- Export serializes `isFavorite`.
- Import restores `isFavorite`.
- Full replacement import preserves favorite values from the imported payload, not the previous local state.

### Regression tests

- Existing diary totals and meal grouping behavior remain unchanged.
- Day screen behavior remains unchanged.
- Goals and settings flows remain unchanged.
- Existing export/import behavior remains unchanged apart from the added `isFavorite` field.

## Out of scope

- Multi-device sync of favorites
- Cloud-backed favorites
- Name-based deduplication heuristics
- Separate sorting or pinning inside favorites
- Showing never-used favorites in `Recent`
- A separate favorites tab

## Recommended implementation shape

1. Add schema field and migration.
2. Extend repository methods and export/import serialization.
3. Add `Recent` query path.
4. Add favorite controls to `Recent`, `Search`, and dialog flows.
5. Add widget and repository regression tests before finishing.

This order keeps the feature deterministic from storage up through UI.
