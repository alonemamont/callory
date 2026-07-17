import 'package:callory/domain/food_source.dart';

class FoodLookupService {
  final FoodSource privateSource;
  final FoodSource externalSource;
  FoodLookupService(this.privateSource, this.externalSource);

  Stream<List<FoodResult>> searchStream(String query) async* {
    final privateResults = await privateSource.searchByName(query);
    yield privateResults;

    final externalResults = await externalSource.searchByName(query);
    final mergedResults = <FoodResult>[...privateResults];
    final seenPrivateIds = privateResults
        .map((result) => result.existingPrivateFoodId)
        .whereType<int>()
        .toSet();
    final privateByBarcode = {
      for (final result in privateResults)
        if (result.barcode != null) result.barcode!: result,
    };

    for (final externalResult in externalResults) {
      final barcode = externalResult.barcode;
      final privateMatch = barcode == null
          ? null
          : privateByBarcode[barcode] ??
              await privateSource.lookupBarcode(barcode);
      if (privateMatch != null) {
        if (seenPrivateIds.add(privateMatch.existingPrivateFoodId!)) {
          mergedResults.add(privateMatch);
        }
        continue;
      }
      mergedResults.add(externalResult);
    }

    yield mergedResults;
  }

  Future<List<FoodResult>> search(String query) => searchStream(query).last;

  Future<FoodResult?> lookupBarcode(String barcode) async {
    final privateMatch = await privateSource.lookupBarcode(barcode);
    if (privateMatch != null) return privateMatch;
    return externalSource.lookupBarcode(barcode);
  }
}
