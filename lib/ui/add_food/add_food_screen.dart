import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:callory/db/database.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/widgets/number_field.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Search'),
            Tab(text: 'Barcode'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RecentTab(),
          _SearchTab(),
          _BarcodeTab(),
          _ManualTab(),
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

  Future<void> _toggleFavorite(FoodResult result) async {
    await ref.read(foodRepositoryProvider).setFavorite(
          result.existingPrivateFoodId!,
          !result.isFavorite,
        );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodResult>>(
      future: ref.read(foodRepositoryProvider).getRecentFoods(
            favoritesOnly: _favoritesOnly,
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? const <FoodResult>[];
        final isFilteredEmpty = _favoritesOnly && results.isEmpty;

        return Column(
          children: [
            SwitchListTile(
              title: const Text('Only favorites'),
              value: _favoritesOnly,
              onChanged: (value) => setState(() => _favoritesOnly = value),
            ),
            if (results.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    isFilteredEmpty
                        ? 'No favorite recent foods yet'
                        : 'No recent foods yet',
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
                        '${result.kcalPer100g.round()} kcal / 100g',
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          result.isFavorite ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () => _toggleFavorite(result),
                      ),
                      onTap: () async {
                        await showEditableFoodDialog(
                          context: context,
                          ref: ref,
                          initial: result,
                        );
                        if (mounted) {
                          setState(() {});
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

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final results = await ref.read(foodLookupServiceProvider).search(query);
    setState(() => _results = results);
  }

  Future<void> _toggleFavorite(FoodResult result) async {
    final repo = ref.read(foodRepositoryProvider);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Search foods'),
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
                  '${result.kcalPer100g.round()} kcal / 100g'
                  '${result.existingPrivateFoodId == null ? '' : ' (in your foods)'}',
                ),
                trailing: IconButton(
                  icon: Icon(
                    result.isFavorite ? Icons.star : Icons.star_border,
                  ),
                  onPressed: () => _toggleFavorite(result),
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
    await showEditableFoodDialog(context: context, ref: ref, initial: result);
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
        final result = await ref.read(foodLookupServiceProvider).lookupBarcode(
              barcode,
            );
        if (!context.mounted) {
          _handlingDetection = false;
          return;
        }
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found — enter it manually')),
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

class _ManualTab extends ConsumerWidget {
  const _ManualTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () => showEditableFoodDialog(
          context: context,
          ref: ref,
          initial: const FoodResult(
            name: '',
            kcalPer100g: 0,
            proteinPer100g: 0,
            fatPer100g: 0,
            carbsPer100g: 0,
          ),
        ),
        child: const Text('Add food manually'),
      ),
    );
  }
}

/// Shows an editable card for a [FoodResult] (from barcode lookup, external
/// search, or a blank manual entry), lets the user adjust fields and grams,
/// saves it to the private food database, and logs a diary entry for it.
Future<void> showEditableFoodDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FoodResult initial,
  String? barcode,
}) async {
  final nameController = TextEditingController(text: initial.name);
  final kcalController = TextEditingController(text: initial.kcalPer100g.toString());
  final proteinController = TextEditingController(text: initial.proteinPer100g.toString());
  final fatController = TextEditingController(text: initial.fatPer100g.toString());
  final carbsController = TextEditingController(text: initial.carbsPer100g.toString());
  final gramsController = TextEditingController(text: '100');
  var isFavorite = initial.isFavorite;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Food details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              NumberField(controller: kcalController, labelText: 'Kcal / 100g'),
              NumberField(controller: proteinController, labelText: 'Protein / 100g'),
              NumberField(controller: fatController, labelText: 'Fat / 100g'),
              NumberField(controller: carbsController, labelText: 'Carbs / 100g'),
              NumberField(controller: gramsController, labelText: 'Grams eaten'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isFavorite,
                title: const Text('Favorite'),
                onChanged: (value) => setState(() => isFavorite = value ?? false),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    ),
  );

  if (confirmed != true) return;

  final kcalPer100g = double.tryParse(kcalController.text) ?? 0;
  final proteinPer100g = double.tryParse(proteinController.text) ?? 0;
  final fatPer100g = double.tryParse(fatController.text) ?? 0;
  final carbsPer100g = double.tryParse(carbsController.text) ?? 0;
  final grams = double.tryParse(gramsController.text) ?? 100;

  final foodRepo = ref.read(foodRepositoryProvider);
  final privateFoodId = initial.existingPrivateFoodId;
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
    await _logEntry(
      ref,
      privateFoodId: privateFoodId,
      name: nameController.text,
      grams: grams,
      kcalPer100g: kcalPer100g,
      proteinPer100g: proteinPer100g,
      fatPer100g: fatPer100g,
      carbsPer100g: carbsPer100g,
    );
    return;
  }

  final source = barcode != null
      ? FoodSourceType.barcode
      : (initial.name.isEmpty ? FoodSourceType.manual : FoodSourceType.copiedExternal);
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
  await _logEntry(
    ref,
    privateFoodId: newId,
    name: nameController.text,
    grams: grams,
    kcalPer100g: kcalPer100g,
    proteinPer100g: proteinPer100g,
    fatPer100g: fatPer100g,
    carbsPer100g: carbsPer100g,
  );
}

Future<void> _logEntry(
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
  await ref.read(diaryRepositoryProvider).addEntry(
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
