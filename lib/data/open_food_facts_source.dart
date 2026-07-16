import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:callory/domain/food_source.dart';

class OpenFoodFactsSource implements FoodSource {
  final http.Client client;
  OpenFoodFactsSource({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<List<FoodResult>> searchByName(String query) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl'
      '?search_terms=${Uri.encodeQueryComponent(query)}'
      '&search_simple=1&action=process&json=1&page_size=20',
    );
    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      return products
          .map((p) => _parseProduct(p as Map<String, dynamic>))
          .whereType<FoodResult>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FoodResult?> lookupBarcode(String barcode) async {
    final uri =
        Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    try {
      final response = await client.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      return _parseProduct(data['product'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  FoodResult? _parseProduct(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    if (nutriments == null) return null;
    final kcal = _asDouble(nutriments['energy-kcal_100g']);
    final protein = _asDouble(nutriments['proteins_100g']);
    final fat = _asDouble(nutriments['fat_100g']);
    final carbs = _asDouble(nutriments['carbohydrates_100g']);
    if (kcal == null || protein == null || fat == null || carbs == null) {
      return null;
    }
    if (!kcal.isFinite || !protein.isFinite || !fat.isFinite || !carbs.isFinite) {
      return null;
    }
    if (kcal < 0 || protein < 0 || fat < 0 || carbs < 0) {
      return null;
    }
    final name = product['product_name'] as String?;
    return FoodResult(
      name: (name != null && name.trim().isNotEmpty) ? name : 'Unknown',
      barcode: product['code'] as String?,
      kcalPer100g: kcal,
      proteinPer100g: protein,
      fatPer100g: fat,
      carbsPer100g: carbs,
    );
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
