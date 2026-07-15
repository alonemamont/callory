import 'package:callory/domain/food_source.dart';

class FoodLookupService {
  final FoodSource privateSource;
  final FoodSource externalSource;
  FoodLookupService(this.privateSource, this.externalSource);

  Future<List<FoodResult>> search(String query) async {
    final privateResults = await privateSource.searchByName(query);
    final externalResults = await externalSource.searchByName(query);
    return [...privateResults, ...externalResults];
  }

  Future<FoodResult?> lookupBarcode(String barcode) async {
    final privateMatch = await privateSource.lookupBarcode(barcode);
    if (privateMatch != null) return privateMatch;
    return externalSource.lookupBarcode(barcode);
  }
}
