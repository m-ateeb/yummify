import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ensure AsyncValue is imported

// -----------------------------
// 🔐 Core Auth Providers
// -----------------------------
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges(); // Emits user on login/logout
});

// --- CRITICAL FIX: userIdProvider now returns AsyncValue<String?> ---
final userIdProvider = Provider<AsyncValue<String?>>((ref) {
  final userAsyncValue = ref.watch(userProvider); // This is an AsyncValue<User?>

  return userAsyncValue.when(
    data: (user) => AsyncValue.data(user?.uid), // If data, extract UID or null
    loading: () => const AsyncValue.loading(), // Propagate loading state
    error: (err, stack) => AsyncValue.error(err, stack), // Propagate error state
  );
});

// -----------------------------
// 👤 User Profile Model and Provider
// -----------------------------
class UserProfile {
  final String uid;
  final String role;
  final String? name;
  final String? email;
  final String? avatarUrl;

  UserProfile({required this.uid, required this.role, this.name, this.email, this.avatarUrl});
}

final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield null;
    } else {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final role = data?['role']?.toString() ?? 'user';

      yield UserProfile(
        uid: user.uid,
        role: role,
        name: data?['name']?.toString() ?? user.displayName,
        email: data?['email']?.toString() ?? user.email,
        avatarUrl: data?['avatarUrl']?.toString() ?? user.photoURL,
      );
    }
  }
});

// Add the app ID provider here since it's a global dependency for Firestore paths
final appIdProvider = Provider<String>((ref) {
  // This gets the __app_id from the environment variables configured in main.dart
  // defaultValue ensures it's always a String, even if env var is not set.
  return const String.fromEnvironment('FLUTTER_WEB_APP_ID', defaultValue: 'default-app-id');
});