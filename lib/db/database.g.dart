// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PrivateFoodsTable extends PrivateFoods
    with TableInfo<$PrivateFoodsTable, PrivateFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrivateFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta(
    'kcalPer100g',
  );
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
    'kcal_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta(
    'proteinPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta(
    'fatPer100g',
  );
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSourceType, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<FoodSourceType>($PrivateFoodsTable.$convertersource);
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    barcode,
    kcalPer100g,
    proteinPer100g,
    fatPer100g,
    carbsPer100g,
    source,
    isFavorite,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'private_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrivateFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('kcal_per100g')) {
      context.handle(
        _kcalPer100gMeta,
        kcalPer100g.isAcceptableOrUnknown(
          data['kcal_per100g']!,
          _kcalPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(
          data['protein_per100g']!,
          _proteinPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('fat_per100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per100g']!, _fatPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per100g']!,
          _carbsPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrivateFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrivateFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      kcalPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per100g'],
      )!,
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100g'],
      )!,
      source: $PrivateFoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrivateFoodsTable createAlias(String alias) {
    return $PrivateFoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSourceType, int, int> $convertersource =
      const EnumIndexConverter<FoodSourceType>(FoodSourceType.values);
}

class PrivateFood extends DataClass implements Insertable<PrivateFood> {
  final int id;
  final String name;
  final String? barcode;
  final double kcalPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final FoodSourceType source;
  final bool isFavorite;
  final DateTime createdAt;
  const PrivateFood({
    required this.id,
    required this.name,
    this.barcode,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    required this.source,
    required this.isFavorite,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['kcal_per100g'] = Variable<double>(kcalPer100g);
    map['protein_per100g'] = Variable<double>(proteinPer100g);
    map['fat_per100g'] = Variable<double>(fatPer100g);
    map['carbs_per100g'] = Variable<double>(carbsPer100g);
    {
      map['source'] = Variable<int>(
        $PrivateFoodsTable.$convertersource.toSql(source),
      );
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrivateFoodsCompanion toCompanion(bool nullToAbsent) {
    return PrivateFoodsCompanion(
      id: Value(id),
      name: Value(name),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      fatPer100g: Value(fatPer100g),
      carbsPer100g: Value(carbsPer100g),
      source: Value(source),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
    );
  }

  factory PrivateFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrivateFood(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      source: $PrivateFoodsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'source': serializer.toJson<int>(
        $PrivateFoodsTable.$convertersource.toJson(source),
      ),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrivateFood copyWith({
    int? id,
    String? name,
    Value<String?> barcode = const Value.absent(),
    double? kcalPer100g,
    double? proteinPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    FoodSourceType? source,
    bool? isFavorite,
    DateTime? createdAt,
  }) => PrivateFood(
    id: id ?? this.id,
    name: name ?? this.name,
    barcode: barcode.present ? barcode.value : this.barcode,
    kcalPer100g: kcalPer100g ?? this.kcalPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    source: source ?? this.source,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
  );
  PrivateFood copyWithCompanion(PrivateFoodsCompanion data) {
    return PrivateFood(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      kcalPer100g: data.kcalPer100g.present
          ? data.kcalPer100g.value
          : this.kcalPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      fatPer100g: data.fatPer100g.present
          ? data.fatPer100g.value
          : this.fatPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      source: data.source.present ? data.source.value : this.source,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrivateFood(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('source: $source, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    barcode,
    kcalPer100g,
    proteinPer100g,
    fatPer100g,
    carbsPer100g,
    source,
    isFavorite,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrivateFood &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.kcalPer100g == this.kcalPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.source == this.source &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class PrivateFoodsCompanion extends UpdateCompanion<PrivateFood> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> barcode;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> fatPer100g;
  final Value<double> carbsPer100g;
  final Value<FoodSourceType> source;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  const PrivateFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.source = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PrivateFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.barcode = const Value.absent(),
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required FoodSourceType source,
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       kcalPer100g = Value(kcalPer100g),
       proteinPer100g = Value(proteinPer100g),
       fatPer100g = Value(fatPer100g),
       carbsPer100g = Value(carbsPer100g),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<PrivateFood> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<double>? kcalPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? carbsPer100g,
    Expression<int>? source,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (kcalPer100g != null) 'kcal_per100g': kcalPer100g,
      if (proteinPer100g != null) 'protein_per100g': proteinPer100g,
      if (fatPer100g != null) 'fat_per100g': fatPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (source != null) 'source': source,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PrivateFoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? barcode,
    Value<double>? kcalPer100g,
    Value<double>? proteinPer100g,
    Value<double>? fatPer100g,
    Value<double>? carbsPer100g,
    Value<FoodSourceType>? source,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
  }) {
    return PrivateFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      kcalPer100g: kcalPer100g ?? this.kcalPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per100g'] = Variable<double>(proteinPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per100g'] = Variable<double>(fatPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $PrivateFoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrivateFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('source: $source, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayDateMeta = const VerificationMeta(
    'dayDate',
  );
  @override
  late final GeneratedColumn<DateTime> dayDate = GeneratedColumn<DateTime>(
    'day_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealNumberMeta = const VerificationMeta(
    'mealNumber',
  );
  @override
  late final GeneratedColumn<int> mealNumber = GeneratedColumn<int>(
    'meal_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayDate, mealNumber, isManual];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_date')) {
      context.handle(
        _dayDateMeta,
        dayDate.isAcceptableOrUnknown(data['day_date']!, _dayDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dayDateMeta);
    }
    if (data.containsKey('meal_number')) {
      context.handle(
        _mealNumberMeta,
        mealNumber.isAcceptableOrUnknown(data['meal_number']!, _mealNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_mealNumberMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day_date'],
      )!,
      mealNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_number'],
      )!,
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class Meal extends DataClass implements Insertable<Meal> {
  final int id;
  final DateTime dayDate;
  final int mealNumber;
  final bool isManual;
  const Meal({
    required this.id,
    required this.dayDate,
    required this.mealNumber,
    required this.isManual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_date'] = Variable<DateTime>(dayDate);
    map['meal_number'] = Variable<int>(mealNumber);
    map['is_manual'] = Variable<bool>(isManual);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      dayDate: Value(dayDate),
      mealNumber: Value(mealNumber),
      isManual: Value(isManual),
    );
  }

  factory Meal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<int>(json['id']),
      dayDate: serializer.fromJson<DateTime>(json['dayDate']),
      mealNumber: serializer.fromJson<int>(json['mealNumber']),
      isManual: serializer.fromJson<bool>(json['isManual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayDate': serializer.toJson<DateTime>(dayDate),
      'mealNumber': serializer.toJson<int>(mealNumber),
      'isManual': serializer.toJson<bool>(isManual),
    };
  }

  Meal copyWith({
    int? id,
    DateTime? dayDate,
    int? mealNumber,
    bool? isManual,
  }) => Meal(
    id: id ?? this.id,
    dayDate: dayDate ?? this.dayDate,
    mealNumber: mealNumber ?? this.mealNumber,
    isManual: isManual ?? this.isManual,
  );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      dayDate: data.dayDate.present ? data.dayDate.value : this.dayDate,
      mealNumber: data.mealNumber.present
          ? data.mealNumber.value
          : this.mealNumber,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('dayDate: $dayDate, ')
          ..write('mealNumber: $mealNumber, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayDate, mealNumber, isManual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.dayDate == this.dayDate &&
          other.mealNumber == this.mealNumber &&
          other.isManual == this.isManual);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<int> id;
  final Value<DateTime> dayDate;
  final Value<int> mealNumber;
  final Value<bool> isManual;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.dayDate = const Value.absent(),
    this.mealNumber = const Value.absent(),
    this.isManual = const Value.absent(),
  });
  MealsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dayDate,
    required int mealNumber,
    this.isManual = const Value.absent(),
  }) : dayDate = Value(dayDate),
       mealNumber = Value(mealNumber);
  static Insertable<Meal> custom({
    Expression<int>? id,
    Expression<DateTime>? dayDate,
    Expression<int>? mealNumber,
    Expression<bool>? isManual,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayDate != null) 'day_date': dayDate,
      if (mealNumber != null) 'meal_number': mealNumber,
      if (isManual != null) 'is_manual': isManual,
    });
  }

  MealsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? dayDate,
    Value<int>? mealNumber,
    Value<bool>? isManual,
  }) {
    return MealsCompanion(
      id: id ?? this.id,
      dayDate: dayDate ?? this.dayDate,
      mealNumber: mealNumber ?? this.mealNumber,
      isManual: isManual ?? this.isManual,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayDate.present) {
      map['day_date'] = Variable<DateTime>(dayDate.value);
    }
    if (mealNumber.present) {
      map['meal_number'] = Variable<int>(mealNumber.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('dayDate: $dayDate, ')
          ..write('mealNumber: $mealNumber, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meals (id)',
    ),
  );
  static const VerificationMeta _privateFoodIdMeta = const VerificationMeta(
    'privateFoodId',
  );
  @override
  late final GeneratedColumn<int> privateFoodId = GeneratedColumn<int>(
    'private_food_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES private_foods (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _foodNameSnapshotMeta = const VerificationMeta(
    'foodNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> foodNameSnapshot = GeneratedColumn<String>(
    'food_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalSnapshotMeta = const VerificationMeta(
    'kcalSnapshot',
  );
  @override
  late final GeneratedColumn<double> kcalSnapshot = GeneratedColumn<double>(
    'kcal_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinSnapshotMeta = const VerificationMeta(
    'proteinSnapshot',
  );
  @override
  late final GeneratedColumn<double> proteinSnapshot = GeneratedColumn<double>(
    'protein_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatSnapshotMeta = const VerificationMeta(
    'fatSnapshot',
  );
  @override
  late final GeneratedColumn<double> fatSnapshot = GeneratedColumn<double>(
    'fat_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsSnapshotMeta = const VerificationMeta(
    'carbsSnapshot',
  );
  @override
  late final GeneratedColumn<double> carbsSnapshot = GeneratedColumn<double>(
    'carbs_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealId,
    privateFoodId,
    foodNameSnapshot,
    grams,
    kcalSnapshot,
    proteinSnapshot,
    fatSnapshot,
    carbsSnapshot,
    occurredAt,
    createdAt,
    updatedAt,
    entryDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('private_food_id')) {
      context.handle(
        _privateFoodIdMeta,
        privateFoodId.isAcceptableOrUnknown(
          data['private_food_id']!,
          _privateFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('food_name_snapshot')) {
      context.handle(
        _foodNameSnapshotMeta,
        foodNameSnapshot.isAcceptableOrUnknown(
          data['food_name_snapshot']!,
          _foodNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodNameSnapshotMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('kcal_snapshot')) {
      context.handle(
        _kcalSnapshotMeta,
        kcalSnapshot.isAcceptableOrUnknown(
          data['kcal_snapshot']!,
          _kcalSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalSnapshotMeta);
    }
    if (data.containsKey('protein_snapshot')) {
      context.handle(
        _proteinSnapshotMeta,
        proteinSnapshot.isAcceptableOrUnknown(
          data['protein_snapshot']!,
          _proteinSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinSnapshotMeta);
    }
    if (data.containsKey('fat_snapshot')) {
      context.handle(
        _fatSnapshotMeta,
        fatSnapshot.isAcceptableOrUnknown(
          data['fat_snapshot']!,
          _fatSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatSnapshotMeta);
    }
    if (data.containsKey('carbs_snapshot')) {
      context.handle(
        _carbsSnapshotMeta,
        carbsSnapshot.isAcceptableOrUnknown(
          data['carbs_snapshot']!,
          _carbsSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsSnapshotMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_id'],
      )!,
      privateFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}private_food_id'],
      ),
      foodNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name_snapshot'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      kcalSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_snapshot'],
      )!,
      proteinSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_snapshot'],
      )!,
      fatSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_snapshot'],
      )!,
      carbsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_snapshot'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;
  final int mealId;
  final int? privateFoodId;
  final String foodNameSnapshot;
  final double grams;
  final double kcalSnapshot;
  final double proteinSnapshot;
  final double fatSnapshot;
  final double carbsSnapshot;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime entryDate;
  const DiaryEntry({
    required this.id,
    required this.mealId,
    this.privateFoodId,
    required this.foodNameSnapshot,
    required this.grams,
    required this.kcalSnapshot,
    required this.proteinSnapshot,
    required this.fatSnapshot,
    required this.carbsSnapshot,
    required this.occurredAt,
    required this.createdAt,
    this.updatedAt,
    required this.entryDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<int>(mealId);
    if (!nullToAbsent || privateFoodId != null) {
      map['private_food_id'] = Variable<int>(privateFoodId);
    }
    map['food_name_snapshot'] = Variable<String>(foodNameSnapshot);
    map['grams'] = Variable<double>(grams);
    map['kcal_snapshot'] = Variable<double>(kcalSnapshot);
    map['protein_snapshot'] = Variable<double>(proteinSnapshot);
    map['fat_snapshot'] = Variable<double>(fatSnapshot);
    map['carbs_snapshot'] = Variable<double>(carbsSnapshot);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['entry_date'] = Variable<DateTime>(entryDate);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      mealId: Value(mealId),
      privateFoodId: privateFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(privateFoodId),
      foodNameSnapshot: Value(foodNameSnapshot),
      grams: Value(grams),
      kcalSnapshot: Value(kcalSnapshot),
      proteinSnapshot: Value(proteinSnapshot),
      fatSnapshot: Value(fatSnapshot),
      carbsSnapshot: Value(carbsSnapshot),
      occurredAt: Value(occurredAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      entryDate: Value(entryDate),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      privateFoodId: serializer.fromJson<int?>(json['privateFoodId']),
      foodNameSnapshot: serializer.fromJson<String>(json['foodNameSnapshot']),
      grams: serializer.fromJson<double>(json['grams']),
      kcalSnapshot: serializer.fromJson<double>(json['kcalSnapshot']),
      proteinSnapshot: serializer.fromJson<double>(json['proteinSnapshot']),
      fatSnapshot: serializer.fromJson<double>(json['fatSnapshot']),
      carbsSnapshot: serializer.fromJson<double>(json['carbsSnapshot']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'privateFoodId': serializer.toJson<int?>(privateFoodId),
      'foodNameSnapshot': serializer.toJson<String>(foodNameSnapshot),
      'grams': serializer.toJson<double>(grams),
      'kcalSnapshot': serializer.toJson<double>(kcalSnapshot),
      'proteinSnapshot': serializer.toJson<double>(proteinSnapshot),
      'fatSnapshot': serializer.toJson<double>(fatSnapshot),
      'carbsSnapshot': serializer.toJson<double>(carbsSnapshot),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'entryDate': serializer.toJson<DateTime>(entryDate),
    };
  }

  DiaryEntry copyWith({
    int? id,
    int? mealId,
    Value<int?> privateFoodId = const Value.absent(),
    String? foodNameSnapshot,
    double? grams,
    double? kcalSnapshot,
    double? proteinSnapshot,
    double? fatSnapshot,
    double? carbsSnapshot,
    DateTime? occurredAt,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? entryDate,
  }) => DiaryEntry(
    id: id ?? this.id,
    mealId: mealId ?? this.mealId,
    privateFoodId: privateFoodId.present
        ? privateFoodId.value
        : this.privateFoodId,
    foodNameSnapshot: foodNameSnapshot ?? this.foodNameSnapshot,
    grams: grams ?? this.grams,
    kcalSnapshot: kcalSnapshot ?? this.kcalSnapshot,
    proteinSnapshot: proteinSnapshot ?? this.proteinSnapshot,
    fatSnapshot: fatSnapshot ?? this.fatSnapshot,
    carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
    occurredAt: occurredAt ?? this.occurredAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    entryDate: entryDate ?? this.entryDate,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      privateFoodId: data.privateFoodId.present
          ? data.privateFoodId.value
          : this.privateFoodId,
      foodNameSnapshot: data.foodNameSnapshot.present
          ? data.foodNameSnapshot.value
          : this.foodNameSnapshot,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcalSnapshot: data.kcalSnapshot.present
          ? data.kcalSnapshot.value
          : this.kcalSnapshot,
      proteinSnapshot: data.proteinSnapshot.present
          ? data.proteinSnapshot.value
          : this.proteinSnapshot,
      fatSnapshot: data.fatSnapshot.present
          ? data.fatSnapshot.value
          : this.fatSnapshot,
      carbsSnapshot: data.carbsSnapshot.present
          ? data.carbsSnapshot.value
          : this.carbsSnapshot,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('privateFoodId: $privateFoodId, ')
          ..write('foodNameSnapshot: $foodNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('kcalSnapshot: $kcalSnapshot, ')
          ..write('proteinSnapshot: $proteinSnapshot, ')
          ..write('fatSnapshot: $fatSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('entryDate: $entryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealId,
    privateFoodId,
    foodNameSnapshot,
    grams,
    kcalSnapshot,
    proteinSnapshot,
    fatSnapshot,
    carbsSnapshot,
    occurredAt,
    createdAt,
    updatedAt,
    entryDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.privateFoodId == this.privateFoodId &&
          other.foodNameSnapshot == this.foodNameSnapshot &&
          other.grams == this.grams &&
          other.kcalSnapshot == this.kcalSnapshot &&
          other.proteinSnapshot == this.proteinSnapshot &&
          other.fatSnapshot == this.fatSnapshot &&
          other.carbsSnapshot == this.carbsSnapshot &&
          other.occurredAt == this.occurredAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.entryDate == this.entryDate);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<int?> privateFoodId;
  final Value<String> foodNameSnapshot;
  final Value<double> grams;
  final Value<double> kcalSnapshot;
  final Value<double> proteinSnapshot;
  final Value<double> fatSnapshot;
  final Value<double> carbsSnapshot;
  final Value<DateTime> occurredAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> entryDate;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.privateFoodId = const Value.absent(),
    this.foodNameSnapshot = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcalSnapshot = const Value.absent(),
    this.proteinSnapshot = const Value.absent(),
    this.fatSnapshot = const Value.absent(),
    this.carbsSnapshot = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.entryDate = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    this.privateFoodId = const Value.absent(),
    required String foodNameSnapshot,
    required double grams,
    required double kcalSnapshot,
    required double proteinSnapshot,
    required double fatSnapshot,
    required double carbsSnapshot,
    required DateTime occurredAt,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    required DateTime entryDate,
  }) : mealId = Value(mealId),
       foodNameSnapshot = Value(foodNameSnapshot),
       grams = Value(grams),
       kcalSnapshot = Value(kcalSnapshot),
       proteinSnapshot = Value(proteinSnapshot),
       fatSnapshot = Value(fatSnapshot),
       carbsSnapshot = Value(carbsSnapshot),
       occurredAt = Value(occurredAt),
       createdAt = Value(createdAt),
       entryDate = Value(entryDate);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<int>? privateFoodId,
    Expression<String>? foodNameSnapshot,
    Expression<double>? grams,
    Expression<double>? kcalSnapshot,
    Expression<double>? proteinSnapshot,
    Expression<double>? fatSnapshot,
    Expression<double>? carbsSnapshot,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? entryDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (privateFoodId != null) 'private_food_id': privateFoodId,
      if (foodNameSnapshot != null) 'food_name_snapshot': foodNameSnapshot,
      if (grams != null) 'grams': grams,
      if (kcalSnapshot != null) 'kcal_snapshot': kcalSnapshot,
      if (proteinSnapshot != null) 'protein_snapshot': proteinSnapshot,
      if (fatSnapshot != null) 'fat_snapshot': fatSnapshot,
      if (carbsSnapshot != null) 'carbs_snapshot': carbsSnapshot,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (entryDate != null) 'entry_date': entryDate,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? mealId,
    Value<int?>? privateFoodId,
    Value<String>? foodNameSnapshot,
    Value<double>? grams,
    Value<double>? kcalSnapshot,
    Value<double>? proteinSnapshot,
    Value<double>? fatSnapshot,
    Value<double>? carbsSnapshot,
    Value<DateTime>? occurredAt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? entryDate,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      privateFoodId: privateFoodId ?? this.privateFoodId,
      foodNameSnapshot: foodNameSnapshot ?? this.foodNameSnapshot,
      grams: grams ?? this.grams,
      kcalSnapshot: kcalSnapshot ?? this.kcalSnapshot,
      proteinSnapshot: proteinSnapshot ?? this.proteinSnapshot,
      fatSnapshot: fatSnapshot ?? this.fatSnapshot,
      carbsSnapshot: carbsSnapshot ?? this.carbsSnapshot,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entryDate: entryDate ?? this.entryDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (privateFoodId.present) {
      map['private_food_id'] = Variable<int>(privateFoodId.value);
    }
    if (foodNameSnapshot.present) {
      map['food_name_snapshot'] = Variable<String>(foodNameSnapshot.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcalSnapshot.present) {
      map['kcal_snapshot'] = Variable<double>(kcalSnapshot.value);
    }
    if (proteinSnapshot.present) {
      map['protein_snapshot'] = Variable<double>(proteinSnapshot.value);
    }
    if (fatSnapshot.present) {
      map['fat_snapshot'] = Variable<double>(fatSnapshot.value);
    }
    if (carbsSnapshot.present) {
      map['carbs_snapshot'] = Variable<double>(carbsSnapshot.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('privateFoodId: $privateFoodId, ')
          ..write('foodNameSnapshot: $foodNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('kcalSnapshot: $kcalSnapshot, ')
          ..write('proteinSnapshot: $proteinSnapshot, ')
          ..write('fatSnapshot: $fatSnapshot, ')
          ..write('carbsSnapshot: $carbsSnapshot, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('entryDate: $entryDate')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dailyKcalMeta = const VerificationMeta(
    'dailyKcal',
  );
  @override
  late final GeneratedColumn<double> dailyKcal = GeneratedColumn<double>(
    'daily_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyProteinMeta = const VerificationMeta(
    'dailyProtein',
  );
  @override
  late final GeneratedColumn<double> dailyProtein = GeneratedColumn<double>(
    'daily_protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyFatMeta = const VerificationMeta(
    'dailyFat',
  );
  @override
  late final GeneratedColumn<double> dailyFat = GeneratedColumn<double>(
    'daily_fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyCarbsMeta = const VerificationMeta(
    'dailyCarbs',
  );
  @override
  late final GeneratedColumn<double> dailyCarbs = GeneratedColumn<double>(
    'daily_carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalsMode, int> mode =
      GeneratedColumn<int>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GoalsMode>($GoalsTable.$convertermode);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyKcal,
    dailyProtein,
    dailyFat,
    dailyCarbs,
    mode,
    age,
    weightKg,
    heightCm,
    sex,
    activityLevel,
    goalType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_kcal')) {
      context.handle(
        _dailyKcalMeta,
        dailyKcal.isAcceptableOrUnknown(data['daily_kcal']!, _dailyKcalMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyKcalMeta);
    }
    if (data.containsKey('daily_protein')) {
      context.handle(
        _dailyProteinMeta,
        dailyProtein.isAcceptableOrUnknown(
          data['daily_protein']!,
          _dailyProteinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyProteinMeta);
    }
    if (data.containsKey('daily_fat')) {
      context.handle(
        _dailyFatMeta,
        dailyFat.isAcceptableOrUnknown(data['daily_fat']!, _dailyFatMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyFatMeta);
    }
    if (data.containsKey('daily_carbs')) {
      context.handle(
        _dailyCarbsMeta,
        dailyCarbs.isAcceptableOrUnknown(data['daily_carbs']!, _dailyCarbsMeta),
      );
    } else if (isInserting) {
      context.missing(_dailyCarbsMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_kcal'],
      )!,
      dailyProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_protein'],
      )!,
      dailyFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_fat'],
      )!,
      dailyCarbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}daily_carbs'],
      )!,
      mode: $GoalsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}mode'],
        )!,
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalsMode, int, int> $convertermode =
      const EnumIndexConverter<GoalsMode>(GoalsMode.values);
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final double dailyKcal;
  final double dailyProtein;
  final double dailyFat;
  final double dailyCarbs;
  final GoalsMode mode;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? sex;
  final String? activityLevel;
  final String? goalType;
  const Goal({
    required this.id,
    required this.dailyKcal,
    required this.dailyProtein,
    required this.dailyFat,
    required this.dailyCarbs,
    required this.mode,
    this.age,
    this.weightKg,
    this.heightCm,
    this.sex,
    this.activityLevel,
    this.goalType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_kcal'] = Variable<double>(dailyKcal);
    map['daily_protein'] = Variable<double>(dailyProtein);
    map['daily_fat'] = Variable<double>(dailyFat);
    map['daily_carbs'] = Variable<double>(dailyCarbs);
    {
      map['mode'] = Variable<int>($GoalsTable.$convertermode.toSql(mode));
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || goalType != null) {
      map['goal_type'] = Variable<String>(goalType);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      dailyKcal: Value(dailyKcal),
      dailyProtein: Value(dailyProtein),
      dailyFat: Value(dailyFat),
      dailyCarbs: Value(dailyCarbs),
      mode: Value(mode),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      goalType: goalType == null && nullToAbsent
          ? const Value.absent()
          : Value(goalType),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      dailyKcal: serializer.fromJson<double>(json['dailyKcal']),
      dailyProtein: serializer.fromJson<double>(json['dailyProtein']),
      dailyFat: serializer.fromJson<double>(json['dailyFat']),
      dailyCarbs: serializer.fromJson<double>(json['dailyCarbs']),
      mode: $GoalsTable.$convertermode.fromJson(
        serializer.fromJson<int>(json['mode']),
      ),
      age: serializer.fromJson<int?>(json['age']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      sex: serializer.fromJson<String?>(json['sex']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      goalType: serializer.fromJson<String?>(json['goalType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyKcal': serializer.toJson<double>(dailyKcal),
      'dailyProtein': serializer.toJson<double>(dailyProtein),
      'dailyFat': serializer.toJson<double>(dailyFat),
      'dailyCarbs': serializer.toJson<double>(dailyCarbs),
      'mode': serializer.toJson<int>($GoalsTable.$convertermode.toJson(mode)),
      'age': serializer.toJson<int?>(age),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'sex': serializer.toJson<String?>(sex),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'goalType': serializer.toJson<String?>(goalType),
    };
  }

  Goal copyWith({
    int? id,
    double? dailyKcal,
    double? dailyProtein,
    double? dailyFat,
    double? dailyCarbs,
    GoalsMode? mode,
    Value<int?> age = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
    Value<String?> goalType = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    dailyKcal: dailyKcal ?? this.dailyKcal,
    dailyProtein: dailyProtein ?? this.dailyProtein,
    dailyFat: dailyFat ?? this.dailyFat,
    dailyCarbs: dailyCarbs ?? this.dailyCarbs,
    mode: mode ?? this.mode,
    age: age.present ? age.value : this.age,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    sex: sex.present ? sex.value : this.sex,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    goalType: goalType.present ? goalType.value : this.goalType,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      dailyKcal: data.dailyKcal.present ? data.dailyKcal.value : this.dailyKcal,
      dailyProtein: data.dailyProtein.present
          ? data.dailyProtein.value
          : this.dailyProtein,
      dailyFat: data.dailyFat.present ? data.dailyFat.value : this.dailyFat,
      dailyCarbs: data.dailyCarbs.present
          ? data.dailyCarbs.value
          : this.dailyCarbs,
      mode: data.mode.present ? data.mode.value : this.mode,
      age: data.age.present ? data.age.value : this.age,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      sex: data.sex.present ? data.sex.value : this.sex,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('dailyKcal: $dailyKcal, ')
          ..write('dailyProtein: $dailyProtein, ')
          ..write('dailyFat: $dailyFat, ')
          ..write('dailyCarbs: $dailyCarbs, ')
          ..write('mode: $mode, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('sex: $sex, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailyKcal,
    dailyProtein,
    dailyFat,
    dailyCarbs,
    mode,
    age,
    weightKg,
    heightCm,
    sex,
    activityLevel,
    goalType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.dailyKcal == this.dailyKcal &&
          other.dailyProtein == this.dailyProtein &&
          other.dailyFat == this.dailyFat &&
          other.dailyCarbs == this.dailyCarbs &&
          other.mode == this.mode &&
          other.age == this.age &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.sex == this.sex &&
          other.activityLevel == this.activityLevel &&
          other.goalType == this.goalType);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<double> dailyKcal;
  final Value<double> dailyProtein;
  final Value<double> dailyFat;
  final Value<double> dailyCarbs;
  final Value<GoalsMode> mode;
  final Value<int?> age;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<String?> sex;
  final Value<String?> activityLevel;
  final Value<String?> goalType;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.dailyKcal = const Value.absent(),
    this.dailyProtein = const Value.absent(),
    this.dailyFat = const Value.absent(),
    this.dailyCarbs = const Value.absent(),
    this.mode = const Value.absent(),
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.sex = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goalType = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required double dailyKcal,
    required double dailyProtein,
    required double dailyFat,
    required double dailyCarbs,
    required GoalsMode mode,
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.sex = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goalType = const Value.absent(),
  }) : dailyKcal = Value(dailyKcal),
       dailyProtein = Value(dailyProtein),
       dailyFat = Value(dailyFat),
       dailyCarbs = Value(dailyCarbs),
       mode = Value(mode);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<double>? dailyKcal,
    Expression<double>? dailyProtein,
    Expression<double>? dailyFat,
    Expression<double>? dailyCarbs,
    Expression<int>? mode,
    Expression<int>? age,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<String>? sex,
    Expression<String>? activityLevel,
    Expression<String>? goalType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyKcal != null) 'daily_kcal': dailyKcal,
      if (dailyProtein != null) 'daily_protein': dailyProtein,
      if (dailyFat != null) 'daily_fat': dailyFat,
      if (dailyCarbs != null) 'daily_carbs': dailyCarbs,
      if (mode != null) 'mode': mode,
      if (age != null) 'age': age,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (sex != null) 'sex': sex,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goalType != null) 'goal_type': goalType,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<double>? dailyKcal,
    Value<double>? dailyProtein,
    Value<double>? dailyFat,
    Value<double>? dailyCarbs,
    Value<GoalsMode>? mode,
    Value<int?>? age,
    Value<double?>? weightKg,
    Value<double?>? heightCm,
    Value<String?>? sex,
    Value<String?>? activityLevel,
    Value<String?>? goalType,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      dailyKcal: dailyKcal ?? this.dailyKcal,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyFat: dailyFat ?? this.dailyFat,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      mode: mode ?? this.mode,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyKcal.present) {
      map['daily_kcal'] = Variable<double>(dailyKcal.value);
    }
    if (dailyProtein.present) {
      map['daily_protein'] = Variable<double>(dailyProtein.value);
    }
    if (dailyFat.present) {
      map['daily_fat'] = Variable<double>(dailyFat.value);
    }
    if (dailyCarbs.present) {
      map['daily_carbs'] = Variable<double>(dailyCarbs.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>($GoalsTable.$convertermode.toSql(mode.value));
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('dailyKcal: $dailyKcal, ')
          ..write('dailyProtein: $dailyProtein, ')
          ..write('dailyFat: $dailyFat, ')
          ..write('dailyCarbs: $dailyCarbs, ')
          ..write('mode: $mode, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('sex: $sex, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goalType: $goalType')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrivateFoodsTable privateFoods = $PrivateFoodsTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    privateFoods,
    meals,
    diaryEntries,
    goals,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'private_foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('diary_entries', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$PrivateFoodsTableCreateCompanionBuilder =
    PrivateFoodsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> barcode,
      required double kcalPer100g,
      required double proteinPer100g,
      required double fatPer100g,
      required double carbsPer100g,
      required FoodSourceType source,
      Value<bool> isFavorite,
      required DateTime createdAt,
    });
typedef $$PrivateFoodsTableUpdateCompanionBuilder =
    PrivateFoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> barcode,
      Value<double> kcalPer100g,
      Value<double> proteinPer100g,
      Value<double> fatPer100g,
      Value<double> carbsPer100g,
      Value<FoodSourceType> source,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
    });

final class $$PrivateFoodsTableReferences
    extends BaseReferences<_$AppDatabase, $PrivateFoodsTable, PrivateFood> {
  $$PrivateFoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'private_foods__id__diary_entries__private_food_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.privateFoodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrivateFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $PrivateFoodsTable> {
  $$PrivateFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodSourceType, FoodSourceType, int>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.privateFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrivateFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrivateFoodsTable> {
  $$PrivateFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrivateFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrivateFoodsTable> {
  $$PrivateFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get kcalPer100g => $composableBuilder(
    column: $table.kcalPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FoodSourceType, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.privateFoodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrivateFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrivateFoodsTable,
          PrivateFood,
          $$PrivateFoodsTableFilterComposer,
          $$PrivateFoodsTableOrderingComposer,
          $$PrivateFoodsTableAnnotationComposer,
          $$PrivateFoodsTableCreateCompanionBuilder,
          $$PrivateFoodsTableUpdateCompanionBuilder,
          (PrivateFood, $$PrivateFoodsTableReferences),
          PrivateFood,
          PrefetchHooks Function({bool diaryEntriesRefs})
        > {
  $$PrivateFoodsTableTableManager(_$AppDatabase db, $PrivateFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrivateFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrivateFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrivateFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> kcalPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> carbsPer100g = const Value.absent(),
                Value<FoodSourceType> source = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrivateFoodsCompanion(
                id: id,
                name: name,
                barcode: barcode,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                fatPer100g: fatPer100g,
                carbsPer100g: carbsPer100g,
                source: source,
                isFavorite: isFavorite,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> barcode = const Value.absent(),
                required double kcalPer100g,
                required double proteinPer100g,
                required double fatPer100g,
                required double carbsPer100g,
                required FoodSourceType source,
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
              }) => PrivateFoodsCompanion.insert(
                id: id,
                name: name,
                barcode: barcode,
                kcalPer100g: kcalPer100g,
                proteinPer100g: proteinPer100g,
                fatPer100g: fatPer100g,
                carbsPer100g: carbsPer100g,
                source: source,
                isFavorite: isFavorite,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrivateFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diaryEntriesRefs) db.diaryEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diaryEntriesRefs)
                    await $_getPrefetchedData<
                      PrivateFood,
                      $PrivateFoodsTable,
                      DiaryEntry
                    >(
                      currentTable: table,
                      referencedTable: $$PrivateFoodsTableReferences
                          ._diaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PrivateFoodsTableReferences(
                            db,
                            table,
                            p0,
                          ).diaryEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.privateFoodId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PrivateFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrivateFoodsTable,
      PrivateFood,
      $$PrivateFoodsTableFilterComposer,
      $$PrivateFoodsTableOrderingComposer,
      $$PrivateFoodsTableAnnotationComposer,
      $$PrivateFoodsTableCreateCompanionBuilder,
      $$PrivateFoodsTableUpdateCompanionBuilder,
      (PrivateFood, $$PrivateFoodsTableReferences),
      PrivateFood,
      PrefetchHooks Function({bool diaryEntriesRefs})
    >;
typedef $$MealsTableCreateCompanionBuilder =
    MealsCompanion Function({
      Value<int> id,
      required DateTime dayDate,
      required int mealNumber,
      Value<bool> isManual,
    });
typedef $$MealsTableUpdateCompanionBuilder =
    MealsCompanion Function({
      Value<int> id,
      Value<DateTime> dayDate,
      Value<int> mealNumber,
      Value<bool> isManual,
    });

final class $$MealsTableReferences
    extends BaseReferences<_$AppDatabase, $MealsTable, Meal> {
  $$MealsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'meals__id__diary_entries__meal_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.mealId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealNumber => $composableBuilder(
    column: $table.mealNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dayDate => $composableBuilder(
    column: $table.dayDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealNumber => $composableBuilder(
    column: $table.mealNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dayDate =>
      $composableBuilder(column: $table.dayDate, builder: (column) => column);

  GeneratedColumn<int> get mealNumber => $composableBuilder(
    column: $table.mealNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealsTable,
          Meal,
          $$MealsTableFilterComposer,
          $$MealsTableOrderingComposer,
          $$MealsTableAnnotationComposer,
          $$MealsTableCreateCompanionBuilder,
          $$MealsTableUpdateCompanionBuilder,
          (Meal, $$MealsTableReferences),
          Meal,
          PrefetchHooks Function({bool diaryEntriesRefs})
        > {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> dayDate = const Value.absent(),
                Value<int> mealNumber = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
              }) => MealsCompanion(
                id: id,
                dayDate: dayDate,
                mealNumber: mealNumber,
                isManual: isManual,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime dayDate,
                required int mealNumber,
                Value<bool> isManual = const Value.absent(),
              }) => MealsCompanion.insert(
                id: id,
                dayDate: dayDate,
                mealNumber: mealNumber,
                isManual: isManual,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MealsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({diaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diaryEntriesRefs) db.diaryEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diaryEntriesRefs)
                    await $_getPrefetchedData<Meal, $MealsTable, DiaryEntry>(
                      currentTable: table,
                      referencedTable: $$MealsTableReferences
                          ._diaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$MealsTableReferences(
                        db,
                        table,
                        p0,
                      ).diaryEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mealId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealsTable,
      Meal,
      $$MealsTableFilterComposer,
      $$MealsTableOrderingComposer,
      $$MealsTableAnnotationComposer,
      $$MealsTableCreateCompanionBuilder,
      $$MealsTableUpdateCompanionBuilder,
      (Meal, $$MealsTableReferences),
      Meal,
      PrefetchHooks Function({bool diaryEntriesRefs})
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required int mealId,
      Value<int?> privateFoodId,
      required String foodNameSnapshot,
      required double grams,
      required double kcalSnapshot,
      required double proteinSnapshot,
      required double fatSnapshot,
      required double carbsSnapshot,
      required DateTime occurredAt,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      required DateTime entryDate,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<int> mealId,
      Value<int?> privateFoodId,
      Value<String> foodNameSnapshot,
      Value<double> grams,
      Value<double> kcalSnapshot,
      Value<double> proteinSnapshot,
      Value<double> fatSnapshot,
      Value<double> carbsSnapshot,
      Value<DateTime> occurredAt,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime> entryDate,
    });

final class $$DiaryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry> {
  $$DiaryEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MealsTable _mealIdTable(_$AppDatabase db) =>
      db.meals.createAlias('diary_entries__meal_id__meals__id');

  $$MealsTableProcessedTableManager get mealId {
    final $_column = $_itemColumn<int>('meal_id')!;

    final manager = $$MealsTableTableManager(
      $_db,
      $_db.meals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PrivateFoodsTable _privateFoodIdTable(_$AppDatabase db) => db
      .privateFoods
      .createAlias('diary_entries__private_food_id__private_foods__id');

  $$PrivateFoodsTableProcessedTableManager? get privateFoodId {
    final $_column = $_itemColumn<int>('private_food_id');
    if ($_column == null) return null;
    final manager = $$PrivateFoodsTableTableManager(
      $_db,
      $_db.privateFoods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_privateFoodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodNameSnapshot => $composableBuilder(
    column: $table.foodNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalSnapshot => $composableBuilder(
    column: $table.kcalSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinSnapshot => $composableBuilder(
    column: $table.proteinSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatSnapshot => $composableBuilder(
    column: $table.fatSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsSnapshot => $composableBuilder(
    column: $table.carbsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  $$MealsTableFilterComposer get mealId {
    final $$MealsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableFilterComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrivateFoodsTableFilterComposer get privateFoodId {
    final $$PrivateFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.privateFoodId,
      referencedTable: $db.privateFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrivateFoodsTableFilterComposer(
            $db: $db,
            $table: $db.privateFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodNameSnapshot => $composableBuilder(
    column: $table.foodNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalSnapshot => $composableBuilder(
    column: $table.kcalSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinSnapshot => $composableBuilder(
    column: $table.proteinSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatSnapshot => $composableBuilder(
    column: $table.fatSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsSnapshot => $composableBuilder(
    column: $table.carbsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$MealsTableOrderingComposer get mealId {
    final $$MealsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableOrderingComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrivateFoodsTableOrderingComposer get privateFoodId {
    final $$PrivateFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.privateFoodId,
      referencedTable: $db.privateFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrivateFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.privateFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get foodNameSnapshot => $composableBuilder(
    column: $table.foodNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get kcalSnapshot => $composableBuilder(
    column: $table.kcalSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinSnapshot => $composableBuilder(
    column: $table.proteinSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatSnapshot => $composableBuilder(
    column: $table.fatSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsSnapshot => $composableBuilder(
    column: $table.carbsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  $$MealsTableAnnotationComposer get mealId {
    final $$MealsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableAnnotationComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PrivateFoodsTableAnnotationComposer get privateFoodId {
    final $$PrivateFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.privateFoodId,
      referencedTable: $db.privateFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrivateFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.privateFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (DiaryEntry, $$DiaryEntriesTableReferences),
          DiaryEntry,
          PrefetchHooks Function({bool mealId, bool privateFoodId})
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mealId = const Value.absent(),
                Value<int?> privateFoodId = const Value.absent(),
                Value<String> foodNameSnapshot = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> kcalSnapshot = const Value.absent(),
                Value<double> proteinSnapshot = const Value.absent(),
                Value<double> fatSnapshot = const Value.absent(),
                Value<double> carbsSnapshot = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                mealId: mealId,
                privateFoodId: privateFoodId,
                foodNameSnapshot: foodNameSnapshot,
                grams: grams,
                kcalSnapshot: kcalSnapshot,
                proteinSnapshot: proteinSnapshot,
                fatSnapshot: fatSnapshot,
                carbsSnapshot: carbsSnapshot,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                entryDate: entryDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mealId,
                Value<int?> privateFoodId = const Value.absent(),
                required String foodNameSnapshot,
                required double grams,
                required double kcalSnapshot,
                required double proteinSnapshot,
                required double fatSnapshot,
                required double carbsSnapshot,
                required DateTime occurredAt,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime entryDate,
              }) => DiaryEntriesCompanion.insert(
                id: id,
                mealId: mealId,
                privateFoodId: privateFoodId,
                foodNameSnapshot: foodNameSnapshot,
                grams: grams,
                kcalSnapshot: kcalSnapshot,
                proteinSnapshot: proteinSnapshot,
                fatSnapshot: fatSnapshot,
                carbsSnapshot: carbsSnapshot,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                entryDate: entryDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiaryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealId = false, privateFoodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mealId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mealId,
                                referencedTable: $$DiaryEntriesTableReferences
                                    ._mealIdTable(db),
                                referencedColumn: $$DiaryEntriesTableReferences
                                    ._mealIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (privateFoodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.privateFoodId,
                                referencedTable: $$DiaryEntriesTableReferences
                                    ._privateFoodIdTable(db),
                                referencedColumn: $$DiaryEntriesTableReferences
                                    ._privateFoodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (DiaryEntry, $$DiaryEntriesTableReferences),
      DiaryEntry,
      PrefetchHooks Function({bool mealId, bool privateFoodId})
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required double dailyKcal,
      required double dailyProtein,
      required double dailyFat,
      required double dailyCarbs,
      required GoalsMode mode,
      Value<int?> age,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<String?> sex,
      Value<String?> activityLevel,
      Value<String?> goalType,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<double> dailyKcal,
      Value<double> dailyProtein,
      Value<double> dailyFat,
      Value<double> dailyCarbs,
      Value<GoalsMode> mode,
      Value<int?> age,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<String?> sex,
      Value<String?> activityLevel,
      Value<String?> goalType,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyKcal => $composableBuilder(
    column: $table.dailyKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyProtein => $composableBuilder(
    column: $table.dailyProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyFat => $composableBuilder(
    column: $table.dailyFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dailyCarbs => $composableBuilder(
    column: $table.dailyCarbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalsMode, GoalsMode, int> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyKcal => $composableBuilder(
    column: $table.dailyKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyProtein => $composableBuilder(
    column: $table.dailyProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyFat => $composableBuilder(
    column: $table.dailyFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dailyCarbs => $composableBuilder(
    column: $table.dailyCarbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get dailyKcal =>
      $composableBuilder(column: $table.dailyKcal, builder: (column) => column);

  GeneratedColumn<double> get dailyProtein => $composableBuilder(
    column: $table.dailyProtein,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dailyFat =>
      $composableBuilder(column: $table.dailyFat, builder: (column) => column);

  GeneratedColumn<double> get dailyCarbs => $composableBuilder(
    column: $table.dailyCarbs,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GoalsMode, int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> dailyKcal = const Value.absent(),
                Value<double> dailyProtein = const Value.absent(),
                Value<double> dailyFat = const Value.absent(),
                Value<double> dailyCarbs = const Value.absent(),
                Value<GoalsMode> mode = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> goalType = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                dailyKcal: dailyKcal,
                dailyProtein: dailyProtein,
                dailyFat: dailyFat,
                dailyCarbs: dailyCarbs,
                mode: mode,
                age: age,
                weightKg: weightKg,
                heightCm: heightCm,
                sex: sex,
                activityLevel: activityLevel,
                goalType: goalType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double dailyKcal,
                required double dailyProtein,
                required double dailyFat,
                required double dailyCarbs,
                required GoalsMode mode,
                Value<int?> age = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> goalType = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                dailyKcal: dailyKcal,
                dailyProtein: dailyProtein,
                dailyFat: dailyFat,
                dailyCarbs: dailyCarbs,
                mode: mode,
                age: age,
                weightKg: weightKg,
                heightCm: heightCm,
                sex: sex,
                activityLevel: activityLevel,
                goalType: goalType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrivateFoodsTableTableManager get privateFoods =>
      $$PrivateFoodsTableTableManager(_db, _db.privateFoods);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
}
