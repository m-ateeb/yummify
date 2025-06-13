import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true); //for local data caching
  await ensureUserInFirestore();
  runApp(const MyApp());
}

Future<void> ensureUserInFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await userDoc.get();
  if (!doc.exists) {
    await userDoc.set({
      'uid': user.uid,
      'id': user.uid, // Ensure 'id' is set for compatibility with UserEntity
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'avatarUrl': user.photoURL,
      'memberSince': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}

// Call this after every login/signup
Future<void> handlePostSignIn() async {
  await ensureUserInFirestore();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe & Health App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
