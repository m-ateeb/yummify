import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMealService {
  final CollectionReference mealsCollection =
  FirebaseFirestore.instance.collection('meals');

  // Search meals by query using precomputed lowercase substrings (searchIndex)
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final snapshot = await mealsCollection
        .where('searchIndex', arrayContains: query.toLowerCase())
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': data['id'],
        'name': data['name'],
        'image': null, // Update if image URL exists in Firestore
      };
    }).toList();
  }

  // Get full nutrition info by meal ID, including serving_description and serving_size
  Future<Map<String, dynamic>> fetchNutrition(String id) async {
    final snapshot = await mealsCollection.where('id', isEqualTo: id).limit(1).get();
    if (snapshot.docs.isEmpty) {
      throw Exception('Meal not found');
    }
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    final nutrition = data['nutrition'] ?? {};
    return {
      'calories': nutrition['calories'],
      'protein': nutrition['protein_g'],
      'fat': nutrition['fat_g'],
      'carbs': nutrition['carbs_g'],
      'fiber': nutrition['fiber_g'],
      'serving_description': data['serving_description'],
      'serving_size': data['serving_size'],
      'image': null, // Add support if your meals have images
    };
  }

  // Fetch serving description by meal ID
  Future<String?> fetchServingDescription(String id) async {
    final snapshot = await mealsCollection.where('id', isEqualTo: id).limit(1).get();
    if (snapshot.docs.isEmpty) {
      throw Exception('Meal not found');
    }
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return data['serving_description'] as String?;
  }

  // Fetch serving size by meal ID
  Future<String?> fetchServingSize(String id) async {
    final snapshot = await mealsCollection.where('id', isEqualTo: id).limit(1).get();
    if (snapshot.docs.isEmpty) {
      throw Exception('Meal not found');
    }
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return data['serving_size'] as String?;
  }

  // Fetch all meal names for suggestions
  Future<List<String>> fetchAllMealNames() async {
    final snapshot = await mealsCollection.get();
    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
        .toList();
  }
}
