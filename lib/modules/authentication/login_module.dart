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
  String? _errorMessage;
  final _confirmPasswordController = TextEditingController();

  Future<void> _login() async {
    try {
      final result = await widget.userDao.loginWithEmailAndPassword(
        widget.emailController.text.trim(),
        widget.passwordController.text.trim(),
      );
      if (result['user'] != null) {
        widget.onLoginSuccess(result['user']);
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
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
          Text(
            _isRegistering ? 'Register' : 'Log in',
            style: const TextStyle(
              color: Color(0xFF48CC6D),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Color(0xFF48CC6D)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF48CC6D)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF48CC6D)),
              ),
            ),
            style: const TextStyle(color: Color(0xFF48CC6D)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            autocorrect: false,
            controller: widget.passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Color(0xFF48CC6D)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF48CC6D)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF48CC6D)),
              ),
            ),
            style: const TextStyle(color: Color(0xFF48CC6D)),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          if (_errorMessage != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_isRegistering)
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Color(0xFF48CC6D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF48CC6D)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF48CC6D)),
                ),
              ),
              style: const TextStyle(color: Color(0xFF48CC6D)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CC6D),
            ),
            child: Text(
              _isRegistering ? 'Register' : 'Login',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isRegistering = !_isRegistering;
              });
            },
            child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _isRegistering ? 'Already have an account? ' : 'Don\'t have an account? ',
                  style: const TextStyle(color: Color(0xFF48CC6D)),
                ),
                TextSpan(
                  text: _isRegistering ? 'Login' : 'Register',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}