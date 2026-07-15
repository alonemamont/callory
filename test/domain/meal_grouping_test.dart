import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/meal_grouping.dart';

void main() {
  const gapWindow = Duration(minutes: 90);

  test('empty input produces no clusters', () {
    final clusters = clusterAutoEntries(
      autoEntries: [],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, isEmpty);
  });

  test('two entries within the gap form a single cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 8, 30)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.mealNumber, 1);
    expect(clusters.single.entryIds, [1, 2]);
  });

  test('entry exactly at the gap boundary joins the same cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 30)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.entryIds, [1, 2]);
  });

  test('entry just past the gap starts a new cluster', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 31)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(2));
    expect(clusters[0].entryIds, [1]);
    expect(clusters[1].entryIds, [2]);
    expect(clusters.map((c) => c.mealNumber).toList(), [1, 2]);
  });

  test('clustering sorts by occurredAt regardless of input order, fixing the insert-in-the-middle case', () {
    // Entry 3 is passed first but its occurredAt falls between entries 1 and 2.
    // All three are within gapWindow of their chronological neighbor, so they
    // must all land in one cluster no matter what order they're supplied in.
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 3, occurredAt: DateTime(2026, 7, 14, 8, 30)),
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
        AutoEntry(id: 2, occurredAt: DateTime(2026, 7, 14, 9, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(1));
    expect(clusters.single.entryIds, [1, 3, 2]);
  });

  test('backdating an entry earlier than everything else never produces a negative-gap false match', () {
    // Old bug: comparing only against "the last meal" let a much-earlier
    // occurredAt produce a negative time difference, which satisfied
    // `<= gapWindow` and silently joined the wrong meal. Sorting first
    // makes this impossible: entry 4 is 5 hours before entry 1, so it must
    // start its own cluster.
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 13, 0)),
        AutoEntry(id: 4, occurredAt: DateTime(2026, 7, 14, 8, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 1,
    );
    expect(clusters, hasLength(2));
    expect(clusters[0].entryIds, [4]);
    expect(clusters[1].entryIds, [1]);
  });

  test('startingMealNumber offsets past existing manual meal numbers', () {
    final clusters = clusterAutoEntries(
      autoEntries: [
        AutoEntry(id: 1, occurredAt: DateTime(2026, 7, 14, 8, 0)),
      ],
      gapWindow: gapWindow,
      startingMealNumber: 6, // e.g. a manual meal already holds number 5
    );
    expect(clusters.single.mealNumber, 6);
  });
}
