import 'dart:convert';
import 'package:http/http.dart' as http;

class EdamamService {
  final String appId = '150c7aad';
  final String appKey = 'bcfed7422caaa0bd741f239aa955fbd8';

  Future<Map<String, dynamic>> analyzeNutrition(String ingredient) async {
    final url = Uri.parse(
      'https://api.edamam.com/api/nutrition-details?app_id=$appId&app_key=$appKey',
    );

    final body = {
      "title": "Recipe",
      "ingr": [ingredient]
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze nutrition: ${response.statusCode} ${response.body}');
    }
  }
}
