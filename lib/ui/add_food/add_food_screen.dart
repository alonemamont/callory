import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/add_food/manual_tab.dart';
import 'package:callory/ui/widgets/number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addFoodTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.addFoodTabRecent),
            Tab(text: loc.addFoodTabSearch),
            Tab(text: loc.addFoodTabBarcode),
            Tab(text: loc.addFoodTabManual),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RecentTab(),
          _SearchTab(),
          _BarcodeTab(),
          ManualTab(),
        ],
      ),
    );
  }
}

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _RecentTab extends ConsumerStatefulWidget {
  const _RecentTab();

  @override
  ConsumerState<_RecentTab> createState() => _RecentTabState();
}

class _RecentTabState extends ConsumerState<_RecentTab> {
  var _favoritesOnly = false;
  late Future<List<FoodResult>> _recentFoods;

  @override
  void initState() {
    super.initState();
    _recentFoods = ref
        .read(foodRepositoryProvider)
        .getRecentFoods(favoritesOnly: _favoritesOnly);
  }

  void _refresh() {
    setState(() {
      _recentFoods = ref
          .read(foodRepositoryProvider)
          .getRecentFoods(favoritesOnly: _favoritesOnly);
    });
  }

  Future<void> _toggleFavorite(FoodResult result) async {
    await ref
        .read(foodRepositoryProvider)
        .setFavorite(result.existingPrivateFoodId!, !result.isFavorite);
    if (mounted) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<List<FoodResult>>(
      future: _recentFoods,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? const <FoodResult>[];
        final isFilteredEmpty = _favoritesOnly && results.isEmpty;

        return Column(
          children: [
            SwitchListTile(
              title: Text(loc.addFoodOnlyFavorites),
              value: _favoritesOnly,
              onChanged: (value) {
                _favoritesOnly = value;
                _refresh();
              },
            ),
            if (results.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    isFilteredEmpty
                        ? loc.addFoodNoFavoriteRecentFoods
                        : loc.addFoodNoRecentFoods,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      title: Text(result.name),
                      subtitle: Text(
                        loc.addFoodKcalPer100g(result.kcalPer100g.round()),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          result.isFavorite ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () => _toggleFavorite(result),
                      ),
                      onTap: () async {
                        await showLogExistingFoodDialog(
                          context: context,
                          ref: ref,
                          food: result,
                        );
                        if (mounted) {
                          _refresh();
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _controller = TextEditingController();
  List<FoodResult> _results = [];
  var _updatingFavorite = false;
  int _searchGeneration = 0;

  Future<void> _search(String query) async {
    final generation = ++_searchGeneration;
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final stream = ref.read(foodLookupServiceProvider).searchStream(query);
    await for (final results in stream) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() => _results = results);
    }
  }

  Future<void> _toggleFavorite(FoodResult result) async {
    if (_updatingFavorite) return;
    final repo = ref.read(foodRepositoryProvider);
    setState(() => _updatingFavorite = true);
    try {
      if (result.existingPrivateFoodId != null) {
        await repo.setFavorite(
          result.existingPrivateFoodId!,
          !result.isFavorite,
        );
      } else if (result.barcode != null) {
        final existing = await repo.findByBarcode(result.barcode!);
        if (existing != null) {
          await repo.setFavorite(existing.existingPrivateFoodId!, true);
        } else {
          await repo.insertFood(
            name: result.name,
            barcode: result.barcode,
            kcalPer100g: result.kcalPer100g,
            proteinPer100g: result.proteinPer100g,
            fatPer100g: result.fatPer100g,
            carbsPer100g: result.carbsPer100g,
            source: FoodSourceType.copiedExternal,
            isFavorite: true,
          );
        }
      } else {
        await repo.insertFood(
          name: result.name,
          barcode: null,
          kcalPer100g: result.kcalPer100g,
          proteinPer100g: result.proteinPer100g,
          fatPer100g: result.fatPer100g,
          carbsPer100g: result.carbsPer100g,
          source: FoodSourceType.copiedExternal,
          isFavorite: true,
        );
      }

      await _search(_controller.text);
    } catch (_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.addFoodFavoriteUpdateFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingFavorite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: loc.addFoodSearchLabel),
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return ListTile(
                title: Text(result.name),
                subtitle: Text(
                  loc.addFoodKcalPer100g(result.kcalPer100g.round()) +
                      (result.existingPrivateFoodId == null
                          ? ''
                          : loc.addFoodInYourFoodsSuffix),
                ),
                trailing: IconButton(
                  icon: Icon(
                    result.isFavorite ? Icons.star : Icons.star_border,
                  ),
                  onPressed: _updatingFavorite
                      ? null
                      : () => _toggleFavorite(result),
                ),
                onTap: () => _openGramsDialog(context, result),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openGramsDialog(BuildContext context, FoodResult result) async {
    final saved = await showEditableFoodDialog(
      context: context,
      ref: ref,
      initial: result,
      barcode: result.barcode,
    );
    if (saved && mounted) {
      await _search(_controller.text);
    }
  }
}

class _BarcodeTab extends ConsumerStatefulWidget {
  const _BarcodeTab();

  @override
  ConsumerState<_BarcodeTab> createState() => _BarcodeTabState();
}

class _BarcodeTabState extends ConsumerState<_BarcodeTab> {
  var _handlingDetection = false;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) async {
        if (_handlingDetection) return;
        final barcode = capture.barcodes.firstOrNull?.rawValue;
        if (barcode == null) return;
        _handlingDetection = true;
        try {
          final result = await ref
              .read(foodLookupServiceProvider)
              .lookupBarcode(barcode);
          if (!context.mounted) return;
          if (result == null) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.addFoodBarcodeNotFound),
              ),
            );
            return;
          }
          await showEditableFoodDialog(
            context: context,
            ref: ref,
            initial: result,
            barcode: barcode,
          );
        } finally {
          _handlingDetection = false;
        }
      },
    );
  }
}

Future<bool> showEditableFoodDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodResult initial,
  String? barcode,
}) async {
  final loc = AppLocalizations.of(context)!;
  final nameController = TextEditingController(text: initial.name);
  final kcalController = TextEditingController(
    text: initial.kcalPer100g.toString(),
  );
  final proteinController = TextEditingController(
    text: initial.proteinPer100g.toString(),
  );
  final fatController = TextEditingController(
    text: initial.fatPer100g.toString(),
  );
  final carbsController = TextEditingController(
    text: initial.carbsPer100g.toString(),
  );
  final gramsController = TextEditingController(text: '100');
  var isFavorite = initial.isFavorite;
  String? errorText;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(loc.addFoodDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: loc.addFoodNameLabel),
              ),
              NumberField(controller: kcalController, labelText: loc.addFoodKcalLabel),
              NumberField(
                controller: proteinController,
                labelText: loc.addFoodProteinLabel,
              ),
              NumberField(controller: fatController, labelText: loc.addFoodFatLabel),
              NumberField(
                controller: carbsController,
                labelText: loc.addFoodCarbsLabel,
              ),
              NumberField(
                controller: gramsController,
                labelText: loc.addFoodGramsEatenLabel,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isFavorite,
                title: Text(loc.addFoodFavoriteLabel),
                onChanged: (value) =>
                    setState(() => isFavorite = value ?? false),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.addFoodCancelButton),
          ),
          TextButton(
            onPressed: () {
              final kcal = double.tryParse(kcalController.text);
              final protein = double.tryParse(proteinController.text);
              final fat = double.tryParse(fatController.text);
              final carbs = double.tryParse(carbsController.text);
              final grams = double.tryParse(gramsController.text);
              final nutrients = [kcal, protein, fat, carbs];
              if (nutrients.any((v) => v == null || !v.isFinite || v < 0)) {
                setState(() => errorText = loc.addFoodNutrientError);
                return;
              }
              if (grams == null || !grams.isFinite || grams <= 0) {
                setState(() => errorText = loc.addFoodGramsError);
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(loc.addFoodSaveButton),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return false;

  final kcalPer100g = double.parse(kcalController.text);
  final proteinPer100g = double.parse(proteinController.text);
  final fatPer100g = double.parse(fatController.text);
  final carbsPer100g = double.parse(carbsController.text);
  final grams = double.parse(gramsController.text);

  final foodRepo = ref.read(foodRepositoryProvider);
  final existingByBarcode = barcode == null
      ? null
      : await foodRepo.findByBarcode(barcode);
  final privateFoodId =
      initial.existingPrivateFoodId ?? existingByBarcode?.existingPrivateFoodId;

  if (privateFoodId != null) {
    await foodRepo.updateFood(
      privateFoodId,
      name: nameController.text,
      barcode: barcode ?? initial.barcode,
      kcalPer100g: kcalPer100g,
      proteinPer100g: proteinPer100g,
      fatPer100g: fatPer100g,
      carbsPer100g: carbsPer100g,
    );
    await foodRepo.setFavorite(privateFoodId, isFavorite);
    await logDiaryEntry(
      ref,
      privateFoodId: privateFoodId,
      name: nameController.text,
      grams: grams,
      kcalPer100g: kcalPer100g,
      proteinPer100g: proteinPer100g,
      fatPer100g: fatPer100g,
      carbsPer100g: carbsPer100g,
    );
    return true;
  }

  final source = barcode != null
      ? FoodSourceType.barcode
      : (initial.name.isEmpty
            ? FoodSourceType.manual
            : FoodSourceType.copiedExternal);
  final newId = await foodRepo.insertFood(
    name: nameController.text,
    barcode: barcode,
    kcalPer100g: kcalPer100g,
    proteinPer100g: proteinPer100g,
    fatPer100g: fatPer100g,
    carbsPer100g: carbsPer100g,
    source: source,
    isFavorite: isFavorite,
  );
  await logDiaryEntry(
    ref,
    privateFoodId: newId,
    name: nameController.text,
    grams: grams,
    kcalPer100g: kcalPer100g,
    proteinPer100g: proteinPer100g,
    fatPer100g: fatPer100g,
    carbsPer100g: carbsPer100g,
  );
  return true;
}

Future<void> logDiaryEntry(
  WidgetRef ref, {
  required int privateFoodId,
  required String name,
  required double grams,
  required double kcalPer100g,
  required double proteinPer100g,
  required double fatPer100g,
  required double carbsPer100g,
}) async {
  final settings = ref.read(settingsServiceProvider);
  final selectedDay = ref.read(selectedDayProvider);
  await ref
      .read(diaryRepositoryProvider)
      .addEntry(
        privateFoodId: privateFoodId,
        foodNameSnapshot: name,
        grams: grams,
        kcalPer100g: kcalPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        entryDate: selectedDay,
        occurredAt: DateTime.now(),
        gapWindow: settings.gapWindow,
      );
}
