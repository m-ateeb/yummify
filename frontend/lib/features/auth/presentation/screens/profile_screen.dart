import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/core/services/firebase_authservice.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService authService = FirebaseAuthService();
    final User? user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text("No user info available")
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(user.displayName ?? user.email ?? "No Name",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(user.email ?? ""),
          ],
        ),
      ),
    );
  }
}
