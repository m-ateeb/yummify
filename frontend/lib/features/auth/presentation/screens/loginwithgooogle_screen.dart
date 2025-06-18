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

  Future<void> _handleSignInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.disconnect();

      final account = await googleSignIn.signIn();

      if (account == null) {
        setState(() {
          _isLoading = false;
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

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

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
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
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