import 'dart:io';

import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('schema v1 migrates to v2 with isFavorite defaulting false', () async {
    final dir = await Directory.systemTemp.createTemp('callory_migration_');
    addTearDown(() async => dir.delete(recursive: true));

    final dbFile = File(p.join(dir.path, 'callory.sqlite'));

    final bootstrapDb = sqlite.sqlite3.open(dbFile.path);
    bootstrapDb.execute('''
      CREATE TABLE private_foods (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT NULL,
        kcal_per100g REAL NOT NULL,
        protein_per100g REAL NOT NULL,
        fat_per100g REAL NOT NULL,
        carbs_per100g REAL NOT NULL,
        source INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    bootstrapDb.execute('''
      CREATE TABLE meals (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        day_date INTEGER NOT NULL,
        meal_number INTEGER NOT NULL,
        is_manual INTEGER NOT NULL DEFAULT 0
      )
    ''');
    bootstrapDb.execute('''
      CREATE TABLE diary_entries (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        meal_id INTEGER NOT NULL,
        private_food_id INTEGER NULL,
        food_name_snapshot TEXT NOT NULL,
        grams REAL NOT NULL,
        kcal_snapshot REAL NOT NULL,
        protein_snapshot REAL NOT NULL,
        fat_snapshot REAL NOT NULL,
        carbs_snapshot REAL NOT NULL,
        occurred_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NULL,
        entry_date INTEGER NOT NULL
      )
    ''');
    bootstrapDb.execute('''
      CREATE TABLE goals (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        daily_kcal REAL NOT NULL,
        daily_protein REAL NOT NULL,
        daily_fat REAL NOT NULL,
        daily_carbs REAL NOT NULL,
        mode INTEGER NOT NULL,
        age INTEGER NULL,
        weight_kg REAL NULL,
        height_cm REAL NULL,
        sex TEXT NULL,
        activity_level TEXT NULL,
        goal_type TEXT NULL
      )
    ''');
    bootstrapDb.execute('''
      INSERT INTO private_foods
      (id, name, barcode, kcal_per100g, protein_per100g, fat_per100g, carbs_per100g, source, created_at)
      VALUES (1, 'Migrated Rice', '111', 130, 3, 0.3, 28, 1, 1735689600000)
    ''');
    bootstrapDb.execute('''
      INSERT INTO meals (id, day_date, meal_number, is_manual)
      VALUES (1, 1783987200000, 1, 0)
    ''');
    bootstrapDb.execute('''
      INSERT INTO diary_entries
      (id, meal_id, private_food_id, food_name_snapshot, grams, kcal_snapshot, protein_snapshot, fat_snapshot, carbs_snapshot, occurred_at, created_at, updated_at, entry_date)
      VALUES (1, 1, 1, 'Migrated Rice', 200, 260, 6, 0.6, 56, 1784001600000, 1784001600000, NULL, 1783987200000)
    ''');
    bootstrapDb.execute('PRAGMA user_version = 1');
    bootstrapDb.dispose();

    final migratedDb = AppDatabase.forTesting(
      NativeDatabase.createInBackground(dbFile),
    );
    addTearDown(() async => migratedDb.close());

    final foods = await migratedDb.select(migratedDb.privateFoods).get();
    final entries = await migratedDb.select(migratedDb.diaryEntries).get();

    expect(foods.single.isFavorite, false);
    expect(entries.single.foodNameSnapshot, 'Migrated Rice');
  });

  test('FoodResult defaults favorite state to false for old call sites', () {
    const result = FoodResult(
      name: 'Oats',
      kcalPer100g: 380,
      proteinPer100g: 13,
      fatPer100g: 7,
      carbsPer100g: 67,
    );

    expect(result.isFavorite, false);
  });
}
