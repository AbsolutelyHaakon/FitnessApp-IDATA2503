// lib/modules/authentication/login_module.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';

class LoginModule extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final UserDao userDao;
  final ValueChanged<User?> onLoginSuccess;

  const LoginModule({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.userDao,
    required this.onLoginSuccess,
    super.key,
  });

  @override
  _LoginModuleState createState() => _LoginModuleState();
}

class _LoginModuleState extends State<LoginModule> {
  bool _isRegistering = false;
  final _confirmPasswordController = TextEditingController();

  Future<void> _login() async {
    try {
      User? user = await widget.userDao.loginWithEmailAndPassword(
        widget.emailController.text.trim(),
        widget.passwordController.text.trim(),
      );
      if (user != null) {
        widget.onLoginSuccess(user);
      } else {
        print('Login failed: Invalid credentials');
      }
    } catch (e) {
      print('Login failed: $e');
    }
  }

  Future<void> _register() async {
    try {
      await widget.userDao.createUserWithEmailAndPassword(
        widget.emailController.text,
        widget.passwordController.text,
      );
      _login(); // Automatically log in the user after successful registration
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          if (_isRegistering)
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != widget.passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (widget.formKey.currentState!.validate()) {
                if (_isRegistering) {
                  _register();
                } else {
                  _login();
                }
              }
            },
            child: Text(_isRegistering ? 'Register' : 'Login'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isRegistering = !_isRegistering;
              });
            },
            child: Text(_isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register'),
          ),
        ],
      ),
    );
  }
}