import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/usda_recall.dart';

// Yamaguchi, ito yung service para sa Food Recalls. 
// Binase ko 'to sa official documentation na binigay (Recall-API-documentation.pdf).
class UsdaRecallService {
  static const String _recallUrl = 'https://www.fsis.usda.gov/fsis/api/recall/v/1';
  static const String _localRecallFallback = 'assets/recall_sample.json';

  static Future<List<UsdaRecall>> fetchRecentRecalls() async {
    try {
      // Step 1: Subukan nating humugot sa remote API.
      // Baka i-block din ito ng CORS sa browser, kaya may fallback din tayo.
      final response = await http.get(Uri.parse(_recallUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UsdaRecall.fromJson(json)).toList();
      } else {
        throw Exception('Recall API unreachable');
      }
    } catch (e) {
      // Mark Dave: Dinisable natin yung fallback para makita mo yung Error State sa UI.
      // Balik mo 'to pagkatapos ng testing para may backup uli.
      print('Recall API Error (Simulated): $e');
      rethrow; // Ipasa ang error sa UI
      
      /* 
      try {
        final String localData = await rootBundle.loadString(_localRecallFallback);
        final List<dynamic> data = json.decode(localData);
        return data.map((json) => UsdaRecall.fromJson(json)).toList();
      } catch (assetError) {
        print('Recall Asset Error: $assetError');
        return [];
      }
      */
    }
  }
}
