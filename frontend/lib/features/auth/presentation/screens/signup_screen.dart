import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/core/services/firebase_authservice.dart';
import '/features/user/presentation/screens/profile_screen.dart';
import '/features/auth/presentation/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TextField(
    controller: _emailController,
    decoration: const InputDecoration(labelText: 'Email'),
    ),
    TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Password'),
    ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Sign Up'),
      ),
      const SizedBox(height: 20),
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        child: const Text('Already have an account? Sign In'),
      ),
    ],
    ),
        ),
    );
  }
}

