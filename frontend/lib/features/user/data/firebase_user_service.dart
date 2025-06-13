import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseUserService {
  final _userCollection = FirebaseFirestore.instance.collection('users');
  final _postsCollection = FirebaseFirestore.instance.collection('posts');
  final _activityCollection = FirebaseFirestore.instance.collection('activities');

  Stream<UserEntity?> userStream(String userId) {
    return _userCollection.doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return UserEntity(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        avatarUrl: data['avatarUrl'],
        memberSince: (data['memberSince'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    });
  }

  Stream<List<Post>> userPostsStream(String userId) {
    return _postsCollection.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList(),
    );
  }

  Stream<List<Activity>> activityHistoryStream(String userId) {
    return _activityCollection.where('userId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Activity(
          id: doc.id,
          type: data['type'] ?? '',
          description: data['description'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList(),
    );
  }

  Future<void> updateUserProfile(String userId, {String? name, String? avatarUrl}) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
    updateData['lastUpdated'] = FieldValue.serverTimestamp();
    await _userCollection.doc(userId).update(updateData);
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    // Password update should be handled via Firebase Auth, not Firestore
    // This is a placeholder
  }

  Future<void> logout() async {
    // Use FirebaseAuth.instance.signOut();
  }

  Future<DocumentSnapshot> getUserDoc(String uid) async {
    return await _userCollection.doc(uid).get();
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    await _userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl ?? '',
      'memberSince': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadUserAvatar(String userId, File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('user_avatars').child('$userId.jpg');
    final uploadTask = await ref.putFile(imageFile);
    if (uploadTask.state == TaskState.success) {
      try {
        return await ref.getDownloadURL();
      } catch (e) {
        throw Exception('Failed to get download URL: $e');
      }
    } else {
      throw Exception('Image upload failed: ${uploadTask.state}');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    // Delete user document
    await _userCollection.doc(userId).delete();
    // Optionally: delete user's posts and activities
    final posts = await _postsCollection.where('userId', isEqualTo: userId).get();
    for (var doc in posts.docs) {
      await doc.reference.delete();
    }
    final activities = await _activityCollection.where('userId', isEqualTo: userId).get();
    for (var doc in activities.docs) {
      await doc.reference.delete();
    }
    // Optionally: delete avatar from storage
    final ref = FirebaseStorage.instance.ref().child('user_avatars').child('$userId.jpg');
    try {
      await ref.delete();
    } catch (_) {}
  }
}