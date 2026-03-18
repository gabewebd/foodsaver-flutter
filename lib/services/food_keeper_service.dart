import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Para sa rootBundle
import '../models/food_keeper.dart';

// Yamaguchi, ito yung service natin para humugot ng data sa USDA.
class FoodKeeperService {
  // Aguiluz: Eto na yung tamang official endpoint mula sa foodsafety.gov!
  // Pero since may CORS issue sa browser, gagamit tayo ng High-Availability GitHub Mirror.
  // Ito ay "Gold Standard" trick para gumana yung real-time fetch sa presentation.
  static const String _apiUrl = 'https://raw.githubusercontent.com/candace-sun/technica-2025/main/backend/foodkeeper.json';
  static const String _localAssetPath = 'assets/foodkeeper_sample.json';

  // Aguiluz: Fetch natin lahat tapos kukuha lang tayo ng isa randomly.
  static Future<FoodKeeperProduct> fetchRandomTip() async {
    // Velasquez: Added 45-second delay to visualize Loading Indicator pre.
    await Future.delayed(const Duration(seconds: 45));
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Transformer: Ang raw USDA structure ay "sheets". I-flatten natin.
        List<dynamic> products = [];
        if (data.containsKey('sheets')) {
          final sheets = data['sheets'] as List;
          final productSheet = sheets.firstWhere(
            (s) => s['name'] == 'Product',
            orElse: () => null,
          );
          
          if (productSheet != null) {
            final rawProductData = productSheet['data'] as List;
            // Ang bawat row ay array ng small objects, i-merge natin into one Map
            products = rawProductData.map((row) {
              Map<String, dynamic> flattened = {};
              for (var entry in row) {
                if (entry is Map) {
                  flattened.addAll(entry.cast<String, dynamic>());
                }
              }
              return flattened;
            }).toList();
          }
        } else {
          // Fallback sa dating structure kung sakali
          products = data['product_data'] ?? [];
        }

        if (products.isEmpty) throw Exception('No products found');
        
        final randomIndex = Random().nextInt(products.length);
        return FoodKeeperProduct.fromJson(products[randomIndex]);
      } else {
        throw Exception('Failed to load from API');
      }
    } catch (e) {
      // Mark Dave: Dinisable natin yung fallback para makita mo yung Error State sa UI.
      // Balik mo 'to pagkatapos ng testing para may backup uli.
      print('FoodKeeper API Error (Simulated): $e');
      rethrow; // Ipasa ang error sa UI
      
      // return _fetchFromLocalAsset();
    }
  }

  static Future<FoodKeeperProduct> _fetchFromLocalAsset() async {
    try {
      final String localData = await rootBundle.loadString(_localAssetPath);
      final Map<String, dynamic> data = json.decode(localData);
      final List<dynamic> products = data['product_data'] ?? [];
      
      if (products.isEmpty) throw Exception('Empty local product list');
      
      final random = Random();
      final randomProductJson = products[random.nextInt(products.length)];
      return FoodKeeperProduct.fromJson(randomProductJson);
    } catch (assetError) {
      print('Asset Error: $assetError');
      throw Exception('Walang nahanap na products sa USDA database.');
    }
  }
}
