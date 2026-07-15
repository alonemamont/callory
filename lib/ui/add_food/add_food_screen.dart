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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'Search'),
            Tab(text: 'Barcode'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
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

class _BarcodeTab extends ConsumerWidget {
  const _BarcodeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileScanner(
      onDetect: (capture) async {
        final barcode = capture.barcodes.firstOrNull?.rawValue;
        if (barcode == null) return;
        final result = await ref.read(foodLookupServiceProvider).lookupBarcode(barcode);
        if (!context.mounted) return;
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

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
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
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
      ],
    ),
  );

  if (confirmed != true) return;

  final kcalPer100g = double.tryParse(kcalController.text) ?? 0;
  final proteinPer100g = double.tryParse(proteinController.text) ?? 0;
  final fatPer100g = double.tryParse(fatController.text) ?? 0;
  final carbsPer100g = double.tryParse(carbsController.text) ?? 0;
  final grams = double.tryParse(gramsController.text) ?? 100;

  final foodRepo = ref.read(foodRepositoryProvider);
  final source = initial.existingPrivateFoodId != null
      ? null // already private, no need to re-insert
      : (barcode != null ? FoodSourceType.barcode : (initial.name.isEmpty ? FoodSourceType.manual : FoodSourceType.copiedExternal));

  final privateFoodId = initial.existingPrivateFoodId ??
      await foodRepo.insertFood(
        name: nameController.text,
        barcode: barcode,
        kcalPer100g: kcalPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        source: source!,
      );

  final settings = ref.read(settingsServiceProvider);
  final selectedDay = ref.read(selectedDayProvider);
  await ref.read(diaryRepositoryProvider).addEntry(
        privateFoodId: privateFoodId,
        foodNameSnapshot: nameController.text,
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
