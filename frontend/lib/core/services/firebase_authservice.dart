import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Email/Password Sign In
  Future<User?> signInWithEmailPassword(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // Email/Password Sign Up
  Future<User?> registerWithEmailPassword(String email, String password) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<String?> uploadImageToCloudinary(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/deplebnn1/image/upload'),
        body: {
          'file': imageUrl,
          'upload_preset': 'yummify',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Cloudinary error: $e');
      return null;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _firebaseAuth.signInWithCredential(credential);
    return result.user;
  }





  // Existing functions...

  Future<void> createUserInFirestore(User? user) async {
  if (user == null) return;
  final userDoc = _firestore.collection('users').doc(user.uid);
  await userDoc.set({
  'uid': user.uid,
  'name': user.displayName ?? '',
  'email': user.email ?? '',
  'photoUrl': user.photoURL ?? '',
  'createdAt': FieldValue.serverTimestamp(),
  });
  }




  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
