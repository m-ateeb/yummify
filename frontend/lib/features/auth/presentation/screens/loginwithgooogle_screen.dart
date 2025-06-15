import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginWithGoogleScreen extends StatefulWidget {
  const LoginWithGoogleScreen({Key? key}) : super(key: key);

  @override
  State<LoginWithGoogleScreen> createState() => _LoginWithGoogleScreenState();
}

class _LoginWithGoogleScreenState extends State<LoginWithGoogleScreen> {
  bool _isLoading = false;
  String? _error;
  Future<GoogleSignInAccount?> _forceGoogleAccountSelection() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    // Step 1: If signed in silently, disconnect to clear session
    final existingUser = await googleSignIn.signInSilently();
    if (existingUser != null) {
      await googleSignIn.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Step 2: Now call signIn to prompt account selection
    return await googleSignIn.signIn();
  }


  Future<void> _handleSignInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final account = await _forceGoogleAccountSelection();

      if (account == null) {
        setState(() {
          _error = 'Sign in canceled by user.';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Check if it's a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Save user info to Firestore if new
      if (isNewUser && user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'avatarUrl': user.photoURL,
          'memberSince': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isNewUser
              ? 'Signed up as ${user?.displayName ?? user?.email}'
              : 'Signed in as ${user?.displayName ?? user?.email}')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Sign in failed: $e';
      });
      print('Google Sign-In error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login or Sign Up with Google')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/g_logo.png',
                height: 24,
                width: 24,
              ),
              label: const Text('Continue with Google'),
              onPressed: _handleSignInWithGoogle,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
