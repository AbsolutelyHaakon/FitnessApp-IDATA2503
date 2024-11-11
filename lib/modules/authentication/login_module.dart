// lib/modules/authentication/login_module.dart
import 'package:fitnessapp_idata2503/pages/social%20and%20account/account_setup.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:flutter_svg/svg.dart';

// Login module for the authentication page
// Contains a form for logging in or registering a new user

// Last edited: 11/11/2024
// Last edited by: Matti Kjellstadli

class LoginModule extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final UserDao userDao;
  final ValueChanged<User?> onLoginSuccess;
  final User? user;

  const LoginModule({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.userDao,
    required this.onLoginSuccess,
    super.key,
    this.user,
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
      final result = await widget.userDao.fireBaseLoginWithEmailAndPassword(
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
      final result =
          await widget.userDao.fireBaseCreateUserWithEmailAndPassword(
        widget.emailController.text,
        widget.passwordController.text,
      );
      if (result['user'] != null) {
        widget.onLoginSuccess(result['user']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AccountSetupPage(user: result['user'])),
        );
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      print('Registration failed: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return Form(
    key: widget.formKey,
    child: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/login.svg',
              width: 100.0, // Set the desired width
              height: 100.0, // Set the desired height
            ),
            Text(
              _isRegistering ? 'Register' : 'Log in',
              style: const TextStyle(
                color: AppColors.fitnessPrimaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              controller: widget.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppColors.fitnessMainColor, fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fitnessModuleColor),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              style: const TextStyle(color: AppColors.fitnessMainColor, fontSize: 16),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16), // Add spacing between the fields
            TextFormField(
              autocorrect: false,
              controller: widget.passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: AppColors.fitnessMainColor, fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fitnessModuleColor),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              style: const TextStyle(color: AppColors.fitnessMainColor, fontSize: 16),
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
                  style: const TextStyle(color: AppColors.fitnessWarningColor),
                ),
              ),
            const SizedBox(height: 16),
            if (_isRegistering)
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: AppColors.fitnessMainColor, fontSize: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessModuleColor),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                style: const TextStyle(color: AppColors.fitnessMainColor, fontSize: 16),
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
            SizedBox(
              width: double.infinity,
              height: 56.0, // Adjust height to match input fields
              child: ElevatedButton(
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
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0), // Same border radius as input fields
                  ),
                ),
                child: Text(
                  _isRegistering ? 'Register' : 'Login',
                  style: const TextStyle(color: AppColors.fitnessPrimaryTextColor, fontSize: 16),
                ),
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
                      style: const TextStyle(color: AppColors.fitnessMainColor),
                    ),
                    TextSpan(
                      text: _isRegistering ? 'Login' : 'Register',
                      style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
