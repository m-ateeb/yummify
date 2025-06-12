import 'auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuthProvider _authProvider;

  AuthRepository(this._authProvider);

  Future<User?> signUp(String email, String password) {
    return _authProvider.signUp(email, password);
  }

  Future<User?> login(String email, String password) {
    return _authProvider.login(email, password);
  }

  Future<void> logout() {
    return _authProvider.logout();
  }

  Stream<User?> get authStateChanges => _authProvider.authStateChanges;

  User? get currentUser => _authProvider.currentUser;
}
