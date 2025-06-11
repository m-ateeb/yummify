import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/features/cookbook/domain/cookbook_entity.dart';

class EdamamRecipeService {
  final String appId = '41937b07'; // Replace with your Recipe API app ID
  final String appKey = '4129000eeb09a165cdfdbe5f5939402a'; // Replace with your Recipe API key
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Searches for recipes by query with optional filters and pagination.
  ///
  /// Pagination: [from] is the start index, [to] is the end index (exclusive).
  /// Edamam defaults to max 100 results; max 100 per request.
  ///
  /// Optional filters: diet, health, cuisineType, mealType (all are lists of strings).
  Future<Map<String, dynamic>> searchRecipes({
    required String query,
    int from = 0,
    int to = 20,
    List<String>? diet,
    List<String>? health,
    List<String>? cuisineType,
    List<String>? mealType,
  }) async {
    final queryParameters = <String, String>{
      'type': 'public',
      'q': query,
      'app_id': appId,
      'app_key': appKey,
      'from': from.toString(),
      'to': to.toString(),
    };

    // Add optional filters as multiple query params
    void addListParams(String key, List<String>? values) {
      if (values != null && values.isNotEmpty) {
        // Edamam expects repeated query params, but Uri doesn't support that well.
        // So we join with ',' because Edamam accepts that too.
        queryParameters[key] = values.join(',');
      }
    }

    addListParams('diet', diet);
    addListParams('health', health);
    addListParams('cuisineType', cuisineType);
    addListParams('mealType', mealType);

    final url = Uri.https('api.edamam.com', '/api/recipes/v2', queryParameters);

    final response = await http.get(url);

    print('Edamam recipe search status: ${response.statusCode}');
    print('URL: $url');
    // For debugging, you can print response body here but comment in prod
    // print('Response: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search recipes: ${response.statusCode}');
    }
  }

  /// Add recipes to Firestore cookbook collection (batch write).
  Future<void> addEdamamRecipes(List<Map<String, dynamic>> recipes) async {
    final batch = _firestore.batch();
    for (var recipe in recipes) {
      final cookbookEntity = CookbookEntity.fromEdamam(recipe);
      final docRef = _firestore.collection('recipes').doc(cookbookEntity.id);
      batch.set(docRef, cookbookEntity.toMap());
    }
    await batch.commit();
  }

  /// Fetches recipes and converts them to List<CookbookEntity>
  /// Supports pagination and optional filters.
  Future<List<CookbookEntity>> fetchRecipes({
    required String query,
    int from = 0,
    int to = 20,
    List<String>? diet,
    List<String>? health,
    List<String>? cuisineType,
    List<String>? mealType,
  }) async {
    final data = await searchRecipes(
      query: query,
      from: from,
      to: to,
      diet: diet,
      health: health,
      cuisineType: cuisineType,
      mealType: mealType,
    );

    final List hits = data['hits'] ?? [];

    return hits
        .map<CookbookEntity>((hit) => CookbookEntity.fromEdamam(hit['recipe']))
        .toList();
  }

  /// No internal state, but you can reset pagination here if you add stateful logic
  void reset() {}
}
