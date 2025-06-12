import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/community/domain/community_post.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all community posts ordered by timestamp descending
  Stream<List<CommunityPost>> getCommunityPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CommunityPost.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Add a new post with userId
  Future<void> addPost(CommunityPost post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final data = post.toMap()..['userId'] = user.uid;
    await _firestore.collection('community_posts').add(data);

  }

  // Update a post by ID with userId
  Future<void> updatePost(String id, CommunityPost post) async {
    final user = FirebaseAuth.instance.currentUser;
    final data = post.toMap()..['userId'] = user?.uid;
    await _firestore.collection('community_posts').doc(id).update(data);
  }

  // Set a post by ID with userId
  Future<void> setPost(String id, CommunityPost post) async {
    final user = FirebaseAuth.instance.currentUser;
    final data = post.toMap()..['userId'] = user?.uid;
    await _firestore.collection('community_posts').doc(id).set(data);
  }

  // Delete a post by ID
  Future<void> deletePost(String id) async {
    await _firestore.collection('community_posts').doc(id).delete();
  }
}