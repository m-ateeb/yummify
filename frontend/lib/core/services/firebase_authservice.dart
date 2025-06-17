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





  // create user

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

  //forgot password
  Future<String?> sendPasswordResetLink(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (methods.isEmpty) {
        return 'No account found for this email.';
      } else if (!methods.contains('password')) {
        return 'This email is registered with a different sign-in method.';
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // null means success
    } catch (e) {
      print('Reset password error: $e');
      return 'Failed to send reset link. Please try again later.';
    }
  }

  Future<String?> sendPasswordResetIfUserExists(String email) async {
    try {
      // Step 1: Check Firestore for a user document with this email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print('📦 Firestore query results: ${userQuery.docs.length}');
      if (userQuery.docs.isNotEmpty) {
        print('📧 Found user: ${userQuery.docs.first.data()}');
      }
      if (userQuery.docs.isEmpty) {
        return 'No user found with this email in our system.';
      }

      // Step 2: Check auth methods
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (!methods.contains('password')) {
        return 'This account uses a different sign-in method (e.g. Google).';
      }

      // Step 3: Send reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // null = success
    } catch (e) {
      print('Password reset error: $e');
      return 'Something went wrong. Please try again.';
    }
  }


}
