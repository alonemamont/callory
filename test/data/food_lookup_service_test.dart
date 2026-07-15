import 'package:flutter_test/flutter_test.dart';
import 'package:callory/domain/food_source.dart';
import 'package:callory/data/food_lookup_service.dart';

class _FakeSource implements FoodSource {
  final List<FoodResult> searchResults;
  final FoodResult? barcodeResult;
  _FakeSource({this.searchResults = const [], this.barcodeResult});

  @override
  Future<List<FoodResult>> searchByName(String query) async => searchResults;

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async => barcodeResult;
}

void main() {
  test('search merges private results before external results', () async {
    final private = _FakeSource(searchResults: [
      const FoodResult(
        name: 'My Yogurt',
        kcalPer100g: 90,
        proteinPer100g: 10,
        fatPer100g: 4,
        carbsPer100g: 4,
        existingPrivateFoodId: 1,
      ),
    ]);
    final external = _FakeSource(searchResults: [
      const FoodResult(
        name: 'Generic Yogurt',
        kcalPer100g: 80,
        proteinPer100g: 8,
        fatPer100g: 3,
        carbsPer100g: 5,
      ),
    ]);
    final service = FoodLookupService(private, external);

    final results = await service.search('yogurt');

    expect(results, hasLength(2));
    expect(results.first.name, 'My Yogurt');
    expect(results.last.name, 'Generic Yogurt');
  });

  test('search keeps local favorite state ahead of external results', () async {
    final private = _FakeSource(searchResults: [
      const FoodResult(
        name: 'My Yogurt',
        kcalPer100g: 90,
        proteinPer100g: 10,
        fatPer100g: 4,
        carbsPer100g: 4,
        existingPrivateFoodId: 1,
        isFavorite: true,
      ),
    ]);
    final external = _FakeSource(searchResults: [
      const FoodResult(
        name: 'Generic Yogurt',
        kcalPer100g: 80,
        proteinPer100g: 8,
        fatPer100g: 3,
        carbsPer100g: 5,
      ),
    ]);

    final service = FoodLookupService(private, external);
    final results = await service.search('yogurt');

    expect(results.first.isFavorite, true);
    expect(results.last.isFavorite, false);
  });

  test('lookupBarcode prefers the private match and skips the external call', () async {
    var externalCalled = false;
    final private = _FakeSource(
      barcodeResult: const FoodResult(
        name: 'My Bar',
        kcalPer100g: 200,
        proteinPer100g: 20,
        fatPer100g: 8,
        carbsPer100g: 15,
        existingPrivateFoodId: 5,
      ),
    );
    final external = _CallTrackingSource(onCalled: () => externalCalled = true);
    final service = FoodLookupService(private, external);

    final result = await service.lookupBarcode('123');

    expect(result!.existingPrivateFoodId, 5);
    expect(externalCalled, false);
  });

  test('lookupBarcode returns the private favorite state untouched', () async {
    final private = _FakeSource(
      barcodeResult: const FoodResult(
        name: 'My Bar',
        kcalPer100g: 200,
        proteinPer100g: 20,
        fatPer100g: 8,
        carbsPer100g: 15,
        existingPrivateFoodId: 5,
        isFavorite: true,
      ),
    );
    final service = FoodLookupService(private, _FakeSource());

    final result = await service.lookupBarcode('123');

    expect(result!.existingPrivateFoodId, 5);
    expect(result.isFavorite, true);
  });

  test('lookupBarcode falls back to external when there is no private match', () async {
    final private = _FakeSource(barcodeResult: null);
    final external = _FakeSource(
      barcodeResult: const FoodResult(
        name: 'External Bar',
        kcalPer100g: 200,
        proteinPer100g: 20,
        fatPer100g: 8,
        carbsPer100g: 15,
      ),
    );
    final service = FoodLookupService(private, external);

    final result = await service.lookupBarcode('123');

    expect(result!.name, 'External Bar');
  });
}

class _CallTrackingSource implements FoodSource {
  final void Function() onCalled;
  _CallTrackingSource({required this.onCalled});

  @override
  Future<List<FoodResult>> searchByName(String query) async => [];

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async {
    onCalled();
    return null;
  }
}
