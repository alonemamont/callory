class FoodResult {
  final String name;
  final String? barcode;
  final double kcalPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  /// Non-null when this result already exists in the user's private food
  /// database (so the UI can skip the "copy to private db" step).
  final int? existingPrivateFoodId;

  const FoodResult({
    required this.name,
    this.barcode,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    this.existingPrivateFoodId,
  });
}

abstract class FoodSource {
  Future<List<FoodResult>> searchByName(String query);
  Future<FoodResult?> lookupBarcode(String barcode);
}
