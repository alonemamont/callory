# Search: Local-First, Streaming Remote Merge — Design

## Problem
`_SearchTabState._search` (`lib/ui/add_food/add_food_screen.dart`) awaits `FoodLookupService.search(query)`, which internally awaits the private (local DB) source and *then* the external (OpenFoodFacts) source sequentially before returning anything. If the remote network call is slow, the user sees nothing — not even their own saved foods — until it finishes.

## Solution
Local results should render as soon as they're ready, without waiting on the remote call. When the remote call resolves, its results are merged in and the list updates again. If the remote call fails, the local results simply stay as-is.

### `FoodLookupService` (`lib/data/food_lookup_service.dart`)
Move the existing merge logic (private results first, then external results deduped/reconciled by barcode against private matches) into a new method:

```dart
Stream<List<FoodResult>> searchStream(String query) async* {
  final privateResults = await privateSource.searchByName(query);
  yield privateResults;

  final externalResults = await externalSource.searchByName(query);
  final mergedResults = <FoodResult>[...privateResults];
  final seenPrivateIds = privateResults
      .map((result) => result.existingPrivateFoodId)
      .whereType<int>()
      .toSet();
  final privateByBarcode = {
    for (final result in privateResults)
      if (result.barcode != null) result.barcode!: result,
  };

  for (final externalResult in externalResults) {
    final barcode = externalResult.barcode;
    final privateMatch = barcode == null
        ? null
        : privateByBarcode[barcode] ??
            await privateSource.lookupBarcode(barcode);
    if (privateMatch != null) {
      if (seenPrivateIds.add(privateMatch.existingPrivateFoodId!)) {
        mergedResults.add(privateMatch);
      }
      continue;
    }
    mergedResults.add(externalResult);
  }

  yield mergedResults;
}
```

- First `yield`: private-only results, as soon as they resolve.
- Second `yield`: the same merged list `search()` returns today.

Keep `Future<List<FoodResult>> search(String query)` as a thin wrapper: `searchStream(query).last`. This preserves the existing public API used by the 6 tests in `food_lookup_service_test.dart` unchanged — they only ever assert on the final merged result.

### Remote failure handling
`OpenFoodFactsSource.searchByName` already wraps its network call in try/catch and returns `[]` on any error. So when the remote call fails, the second `yield` in `searchStream` just equals the first (merging in nothing) — the user keeps seeing their local results, no error surfaced. No new error handling code needed anywhere.

### `_SearchTabState._search` (`lib/ui/add_food/add_food_screen.dart`)
Replace the current single `await ... .search(query)` with a subscription to `.searchStream(query)`, calling `setState(() => _results = event)` for each emitted list. The existing `_searchGeneration` counter (incremented per call, already used to discard a stale slow response that arrives after a newer query started) guards **every** emitted event, not just a single final result — same mechanism as today, just checked per-yield instead of once.

An empty/blank query continues to short-circuit directly to `_results = []`, no stream started.

## Out of scope
- No changes to result ordering/dedup rules (private-first, barcode-reconciled) — only when they become visible.
- No changes to `lookupBarcode`, barcode-tab, or favorite-toggle behavior.
- No new UI (no separate loading spinner per source) — the list itself updates in place as new data arrives.

## Testing
- `food_lookup_service_test.dart`: new test asserting `searchStream(query)` emits exactly two events, in order — `[privateOnly, merged]` — reusing the existing "merges private results before external results" fixture shape.
- `add_food_screen_test.dart`: new test — seed a private food via the existing `seedPrivateFood` helper, use the existing `_SlowThenFastSource` fake (200ms-delayed external response) as the external source, submit `slow-query`, `pump()` briefly and assert the private result is visible while the slow remote result is not yet, then `pumpAndSettle` and assert both are visible.
- Existing "a stale slow search response does not overwrite a newer fast search" test is unaffected — same generation-guard, now applied per-event instead of once — and must continue to pass unmodified.
