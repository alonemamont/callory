class AutoEntry {
  final int id;
  final DateTime occurredAt;

  const AutoEntry({required this.id, required this.occurredAt});
}

class MealCluster {
  final int mealNumber;
  final List<int> entryIds;

  const MealCluster({required this.mealNumber, required this.entryIds});
}

/// Deterministically clusters [autoEntries] (which must already exclude any
/// entry currently in a manual meal) into meals using rolling-gap grouping.
/// Always re-derives the full clustering from a fresh sort — there is no
/// incremental "compare to the last meal" step, so inserting an entry
/// anywhere in the day (including earlier than existing entries) is handled
/// correctly by construction.
List<MealCluster> clusterAutoEntries({
  required List<AutoEntry> autoEntries,
  required Duration gapWindow,
  required int startingMealNumber,
}) {
  final sorted = [...autoEntries]..sort((a, b) {
      final byTime = a.occurredAt.compareTo(b.occurredAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });

  final clusters = <MealCluster>[];
  var mealNumber = startingMealNumber;
  List<int>? currentIds;
  DateTime? previousOccurredAt;

  for (final entry in sorted) {
    final startsNewCluster = currentIds == null ||
        entry.occurredAt.difference(previousOccurredAt!) > gapWindow;

    if (startsNewCluster) {
      currentIds = <int>[];
      clusters.add(MealCluster(mealNumber: mealNumber, entryIds: currentIds));
      mealNumber++;
    }

    currentIds.add(entry.id);
    previousOccurredAt = entry.occurredAt;
  }

  return clusters;
}
