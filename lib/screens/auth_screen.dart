import 'package:firebase_auth/firebase_auth.dart'; // Import this to handle Firebase specific errors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLogin = true;
  bool _isLoading = false;

  // Helper function to translate technical errors into human text
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Try a longer one.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Authentication failed. (${error.code})';
      }
    }
    // Fallback for non-Firebase errors
    return 'An unexpected error occurred. Please try again.';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (_isLogin) {
        await auth.signIn(_email, _password);
      } else {
        await auth.signUp(_email, _password);
      }
      // Navigation is handled by the StreamBuilder in SplashScreen
    } catch (e) {
      if (!mounted) return;
      
      // Use the helper function to get a nice message
      final String niceMessage = _handleAuthError(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(niceMessage),
          backgroundColor: Colors.redAccent, // Make it red so they know it's an error
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter an email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                  onSaved: (val) => _email = val!.trim(), // Trim whitespace just in case
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (val) {
                     if (val == null || val.isEmpty) return 'Please enter a password';
                     if (val.length < 6) return 'Password must be at least 6 characters';
                     return null;
                  },
                  onSaved: (val) => _password = val!,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_isLogin ? 'Login' : 'Sign Up'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Create new account' : 'I already have an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}