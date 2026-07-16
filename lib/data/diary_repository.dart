import 'package:drift/drift.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/meal_grouping.dart';
import 'package:callory/domain/entry_rescale.dart';

class DiaryRepository {
  final AppDatabase db;
  DiaryRepository(this.db);

  DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<int> addEntry({
    int? privateFoodId,
    required String foodNameSnapshot,
    required double grams,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required DateTime entryDate,
    required DateTime occurredAt,
    required Duration gapWindow,
  }) async {
    if (grams <= 0) {
      throw ArgumentError.value(grams, 'grams', 'must be positive');
    }
    final dayStart = _dayStart(entryDate);
    final ratio = grams / 100.0;

    return db.transaction(() async {
      // Insert into a throwaway placeholder meal — regroupDay always
      // rebuilds the auto partition from scratch and will assign this
      // entry (and delete the placeholder, since it'll be empty) to the
      // correct cluster in one consistent pass.
      final placeholderMealId = await db.into(db.meals).insert(
            MealsCompanion.insert(dayDate: dayStart, mealNumber: 0),
          );

      final entryId = await db.into(db.diaryEntries).insert(
            DiaryEntriesCompanion.insert(
              mealId: placeholderMealId,
              privateFoodId: Value(privateFoodId),
              foodNameSnapshot: foodNameSnapshot,
              grams: grams,
              kcalSnapshot: kcalPer100g * ratio,
              proteinSnapshot: proteinPer100g * ratio,
              fatSnapshot: fatPer100g * ratio,
              carbsSnapshot: carbsPer100g * ratio,
              occurredAt: occurredAt,
              createdAt: DateTime.now(),
              entryDate: dayStart,
            ),
          );

      await regroupDay(dayStart, gapWindow);
      return entryId;
    });
  }

  Future<void> updateEntryGrams(int entryId, double newGrams) async {
    if (newGrams <= 0) {
      throw ArgumentError.value(newGrams, 'newGrams', 'must be positive');
    }
    final entry =
        await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .getSingle();

    final rescaled = rescaleSnapshot(
      original: NutrientSnapshot(
        kcal: entry.kcalSnapshot,
        protein: entry.proteinSnapshot,
        fat: entry.fatSnapshot,
        carbs: entry.carbsSnapshot,
      ),
      oldGrams: entry.grams,
      newGrams: newGrams,
    );

    await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
        .write(DiaryEntriesCompanion(
      grams: Value(newGrams),
      kcalSnapshot: Value(rescaled.kcal),
      proteinSnapshot: Value(rescaled.protein),
      fatSnapshot: Value(rescaled.fat),
      carbsSnapshot: Value(rescaled.carbs),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateEntryOccurredAt(
    int entryId,
    DateTime newOccurredAt,
    Duration gapWindow,
  ) async {
    await db.transaction(() async {
      final entry = await (db.select(db.diaryEntries)
            ..where((e) => e.id.equals(entryId)))
          .getSingle();

      await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
          .write(DiaryEntriesCompanion(
        occurredAt: Value(newOccurredAt),
        updatedAt: Value(DateTime.now()),
      ));

      await regroupDay(entry.entryDate, gapWindow);
    });
  }

  Future<void> deleteEntry(int entryId, Duration gapWindow) async {
    final entry =
        await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .getSingle();

    await db.transaction(() async {
      await (db.delete(db.diaryEntries)..where((e) => e.id.equals(entryId)))
          .go();
      await regroupDay(entry.entryDate, gapWindow);
      // regroupDay only reaps empty auto meals (it never touches manual
      // meal membership), so if the deleted entry belonged to a manual
      // meal, clean that up explicitly here.
      await _deleteMealIfEmpty(entry.mealId);
    });
  }

  /// Full deterministic regroup of the auto partition for [date], per the
  /// spec's "Meal grouping algorithm": every auto (non-manual) meal for the
  /// day is rebuilt from scratch via [clusterAutoEntries] on every call, so
  /// there is never an incremental "compare to the last meal" step. Manual
  /// meals and their entries are never touched. Empty auto meals left behind
  /// by the rebuild are deleted; manual meals are never deleted here (even
  /// if empty) since regroupDay never changes their entry membership — a
  /// manual meal emptied by [deleteEntry] or [moveEntryToMeal] is cleaned up
  /// by those methods directly.
  Future<void> regroupDay(DateTime date, Duration gapWindow) async {
    final dayStart = _dayStart(date);
    await db.transaction(() async {
      final meals =
          await (db.select(db.meals)..where((m) => m.dayDate.equals(dayStart)))
              .get();
      final manualMealIds =
          meals.where((m) => m.isManual).map((m) => m.id).toSet();
      final maxManualNumber = meals
          .where((m) => m.isManual)
          .fold<int>(0, (max, m) => m.mealNumber > max ? m.mealNumber : max);

      final entries = await (db.select(db.diaryEntries)
            ..where((e) => e.entryDate.equals(dayStart)))
          .get();
      final autoEntries = entries
          .where((e) => !manualMealIds.contains(e.mealId))
          .map((e) => AutoEntry(id: e.id, occurredAt: e.occurredAt))
          .toList();

      final clusters = clusterAutoEntries(
        autoEntries: autoEntries,
        gapWindow: gapWindow,
        startingMealNumber: maxManualNumber + 1,
      );

      for (final cluster in clusters) {
        final newMealId = await db.into(db.meals).insert(
              MealsCompanion.insert(
                dayDate: dayStart,
                mealNumber: cluster.mealNumber,
              ),
            );
        for (final entryId in cluster.entryIds) {
          await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
              .write(DiaryEntriesCompanion(mealId: Value(newMealId)));
        }
      }

      // Clean up auto meals now left with zero entries. Manual meals are
      // never reaped here, since regroupDay never reassigns their entries —
      // an untouched empty manual meal (e.g. just created, not yet
      // populated) must survive an unrelated regroup.
      for (final meal in meals) {
        if (manualMealIds.contains(meal.id)) continue;
        final remaining = await (db.select(db.diaryEntries)
              ..where((e) => e.mealId.equals(meal.id)))
            .get();
        if (remaining.isEmpty) {
          await (db.delete(db.meals)..where((m) => m.id.equals(meal.id))).go();
        }
      }
    });
  }

  Future<void> moveEntryToMeal(int entryId, int targetMealId) async {
    await db.transaction(() async {
      final entry =
          await (db.select(db.diaryEntries)..where((e) => e.id.equals(entryId)))
              .getSingle();
      final sourceMealId = entry.mealId;

      await (db.update(db.meals)..where((m) => m.id.equals(targetMealId)))
          .write(const MealsCompanion(isManual: Value(true)));
      await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
          .write(DiaryEntriesCompanion(
        mealId: Value(targetMealId),
        updatedAt: Value(DateTime.now()),
      ));

      if (sourceMealId != targetMealId) {
        await _deleteMealIfEmpty(sourceMealId);
      }
    });
  }

  Future<int> splitEntriesIntoNewMeal({
    required List<int> entryIds,
    required DateTime date,
    required int newMealNumber,
  }) async {
    return db.transaction(() async {
      final newMealId = await createManualMeal(date, newMealNumber);
      final sourceMealIds = <int>{};

      for (final entryId in entryIds) {
        final entry = await (db.select(db.diaryEntries)
              ..where((e) => e.id.equals(entryId)))
            .getSingle();
        sourceMealIds.add(entry.mealId);
        await (db.update(db.diaryEntries)..where((e) => e.id.equals(entryId)))
            .write(DiaryEntriesCompanion(
          mealId: Value(newMealId),
          updatedAt: Value(DateTime.now()),
        ));
      }

      for (final sourceMealId in sourceMealIds) {
        // A meal a split was carved out of is considered manually curated
        // even for the entries left behind, so auto-regroup never re-merges them.
        await (db.update(db.meals)..where((m) => m.id.equals(sourceMealId)))
            .write(const MealsCompanion(isManual: Value(true)));
        await _deleteMealIfEmpty(sourceMealId);
      }

      return newMealId;
    });
  }

  Future<void> mergeMeals({
    required int keepMealId,
    required int otherMealId,
  }) async {
    await db.transaction(() async {
      await (db.update(db.diaryEntries)..where((e) => e.mealId.equals(otherMealId)))
          .write(DiaryEntriesCompanion(
        mealId: Value(keepMealId),
        updatedAt: Value(DateTime.now()),
      ));
      await (db.update(db.meals)..where((m) => m.id.equals(keepMealId)))
          .write(const MealsCompanion(isManual: Value(true)));
      await (db.delete(db.meals)..where((m) => m.id.equals(otherMealId))).go();
    });
  }

  Future<void> _deleteMealIfEmpty(int mealId) async {
    final remaining = await (db.select(db.diaryEntries)
          ..where((e) => e.mealId.equals(mealId)))
        .get();
    if (remaining.isEmpty) {
      await (db.delete(db.meals)..where((m) => m.id.equals(mealId))).go();
    }
  }

  Future<int> createManualMeal(DateTime date, int mealNumber) {
    return db.into(db.meals).insert(MealsCompanion.insert(
          dayDate: _dayStart(date),
          mealNumber: mealNumber,
          isManual: const Value(true),
        ));
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) {
    final dayStart = _dayStart(date);
    return (db.select(db.diaryEntries)
          ..where((e) => e.entryDate.equals(dayStart))
          ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]))
        .get();
  }

  Future<List<Meal>> getMealsForDate(DateTime date) {
    final dayStart = _dayStart(date);
    return (db.select(db.meals)
          ..where((m) => m.dayDate.equals(dayStart))
          ..orderBy([(m) => OrderingTerm.asc(m.mealNumber)]))
        .get();
  }
}
