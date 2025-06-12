import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/cookbook_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CookbookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  Future<User> _requireUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user;
  }

  Future<List<CookbookEntity>> fetchUserRecipes({int limit = 10}) async {
    await _requireUser();
    if (!_hasMore) return [];

    Query query = _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }

    _lastDoc = snapshot.docs.last;

    return snapshot.docs.map((doc) {
      return CookbookEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<List<CookbookEntity>> fetchPublicRecipes({int limit = 10}) async {
    await _requireUser();
    if (!_hasMore) return [];

    Query query = _firestore
        .collection('recipes')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }

    _lastDoc = snapshot.docs.last;

    return snapshot.docs.map((doc) {
      return CookbookEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<CookbookEntity> getRecipeById(String id) async {
    await _requireUser();
    final doc = await _firestore.collection('recipes').doc(id).get();
    if (!doc.exists) {
      throw Exception('Recipe not found');
    }
    return CookbookEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> addRecipe(CookbookEntity recipe) async {
    final user = await _requireUser();
    final data = recipe.toMap();
    data['authorId'] = user.uid;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('recipes').add(data);
  }

  Future<void> updateRecipe(CookbookEntity recipe) async {
    await _requireUser();
    final data = recipe.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('recipes').doc(recipe.id).update(data);
  }

  Future<void> deleteRecipe(String id) async {
    await _requireUser();
    await _firestore.collection('recipes').doc(id).delete();
  }

  void resetPagination() {
    _lastDoc = null;
    _hasMore = true;
  }




}