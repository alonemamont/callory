import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

enum FoodSourceType { barcode, manual, copiedExternal }

enum GoalsMode { calculated, manual }

class PrivateFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()(); // intentionally not unique — see spec "Domain rules and constraints"
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get carbsPer100g => real()();
  IntColumn get source => intEnum<FoodSourceType>()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dayDate => dateTime()();
  IntColumn get mealNumber => integer()();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
}

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId => integer().references(Meals, #id)();
  IntColumn get privateFoodId => integer()
      .nullable()
      .references(PrivateFoods, #id, onDelete: KeyAction.setNull)();
  TextColumn get foodNameSnapshot => text()();
  RealColumn get grams => real()();
  RealColumn get kcalSnapshot => real()();
  RealColumn get proteinSnapshot => real()();
  RealColumn get fatSnapshot => real()();
  RealColumn get carbsSnapshot => real()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get entryDate => dateTime()();
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get dailyKcal => real()();
  RealColumn get dailyProtein => real()();
  RealColumn get dailyFat => real()();
  RealColumn get dailyCarbs => real()();
  IntColumn get mode => intEnum<GoalsMode>()();
  IntColumn get age => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get activityLevel => text().nullable()();
  TextColumn get goalType => text().nullable()();
}

@DriftDatabase(tables: [PrivateFoods, Meals, DiaryEntries, Goals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(privateFoods, privateFoods.isFavorite);
            await customStatement('''
              UPDATE private_foods
              SET is_favorite = 0
              WHERE is_favorite IS NULL
            ''');
          }
        },
        beforeOpen: (details) async {
          // Required for the DiaryEntries.privateFoodId ON DELETE SET NULL
          // action to actually fire — SQLite does not enforce FKs by default.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'callory.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
