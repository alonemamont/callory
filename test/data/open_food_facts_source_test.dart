import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:callory/data/open_food_facts_source.dart';

void main() {
  test('searchByName parses a successful product list response', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), contains('search_terms=milk'));
      return http.Response(
        jsonEncode({
          'products': [
            {
              'product_name': 'Whole Milk',
              'code': '111',
              'nutriments': {
                'energy-kcal_100g': 61,
                'proteins_100g': 3.2,
                'fat_100g': 3.3,
                'carbohydrates_100g': 4.8,
              },
            },
          ],
        }),
        200,
      );
    });
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('milk');

    expect(results, hasLength(1));
    expect(results.first.name, 'Whole Milk');
    expect(results.first.kcalPer100g, 61);
    expect(results.first.existingPrivateFoodId, isNull);
  });

  test('searchByName returns an empty list on a non-200 response', () async {
    final client = MockClient((request) async => http.Response('error', 500));
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');

    expect(results, isEmpty);
  });

  test('lookupBarcode returns null when the product is not found', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({'status': 0}),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final result = await source.lookupBarcode('0000000000000');

    expect(result, isNull);
  });

  test('lookupBarcode parses a found product', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Greek Yogurt',
              'code': '222',
              'nutriments': {
                'energy-kcal_100g': 90,
                'proteins_100g': 10,
                'fat_100g': 4,
                'carbohydrates_100g': 4,
              },
            },
          }),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final result = await source.lookupBarcode('222');

    expect(result, isNotNull);
    expect(result!.name, 'Greek Yogurt');
    expect(result.barcode, '222');
  });

  test('products missing nutriment data are skipped, not crashed on', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'products': [
              {'product_name': 'No Nutrients Item', 'code': '333'},
            ],
          }),
          200,
        ));
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');

    expect(results, isEmpty);
  });

  test('a network timeout degrades to an empty result instead of crashing', () async {
    final client = MockClient((request) async {
      throw TimeoutException('simulated network timeout');
    });
    final source = OpenFoodFactsSource(client: client);

    final results = await source.searchByName('anything');
    final barcodeResult = await source.lookupBarcode('123');

    expect(results, isEmpty);
    expect(barcodeResult, isNull);
  });
}
