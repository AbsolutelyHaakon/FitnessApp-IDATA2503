// ignore_for_file: avoid_print

import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/account_setup.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:flutter_svg/svg.dart';

/// This class represents the login module for the authentication page.
/// It contains a form for logging in or registering a new user.
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
  bool _isRegistering = false; // Flag to check if the user is registering
  String? _errorMessage; // Error message to display
  final _confirmPasswordController =
      TextEditingController(); // Controller for confirm password field

  // Function to handle login
  Future<void> _login() async {
    try {
      final result = await widget.userDao.fireBaseLoginWithEmailAndPassword(
        widget.emailController.text.trim(),
        widget.passwordController.text.trim(),
      );
      if (result['user'] != null) {
        final WorkoutDao workoutDao = WorkoutDao();
        final UserWorkoutsDao userWorkoutsDao = UserWorkoutsDao();

        setState(() {
          activeWorkoutIndex = 0;
          activeWorkoutName.value = '';
          activeUserWorkoutId.value = '';
          activeWorkoutId.value = '';
          hasActiveWorkout.value = false;
        });

        await workoutDao.localSetAllInactive();
        await userWorkoutsDao.localSetAllInactive();

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

  // Function to handle registration
  Future<void> _register() async {
    if (await widget.userDao
        .fireBaseCheckIfEmailExists(widget.emailController.text)) {
      setState(() {
        _errorMessage = 'An account already exists for that email';
        return;
      });
    }
    try {
      final result =
          await widget.userDao.fireBaseCreateUserWithEmailAndPassword(
        widget.emailController.text,
        widget.passwordController.text,
      );
      if (result['user'] != null) {
        widget.onLoginSuccess(result['user']);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const AccountSetupPage()),
        );
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/login.svg',
              width: 100.0,
              height: 100.0,
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
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      controller: widget.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessMainColor, fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessModuleColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessMainColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessWarningColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessWarningColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 12.0),
                        errorStyle: TextStyle(
                          color: AppColors.fitnessWarningColor,
                          fontSize: 12,
                        ),
                      ),
                      style: const TextStyle(
                          color: AppColors.fitnessMainColor, fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                        height: 16), // Add spacing between the fields
                    TextFormField(
                      autocorrect: false,
                      controller: widget.passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessMainColor, fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessModuleColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessMainColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessWarningColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.fitnessWarningColor),
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 12.0),
                        errorStyle: TextStyle(
                          color: AppColors.fitnessWarningColor,
                          fontSize: 12,
                        ),
                      ),
                      style: const TextStyle(
                          color: AppColors.fitnessMainColor, fontSize: 16),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_isRegistering)
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                              color: AppColors.fitnessMainColor, fontSize: 16),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.fitnessModuleColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.fitnessMainColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.fitnessWarningColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.fitnessWarningColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 12.0),
                          errorStyle: TextStyle(
                            color: AppColors.fitnessWarningColor,
                            fontSize: 12,
                          ),
                        ),
                        style: const TextStyle(
                            color: AppColors.fitnessMainColor, fontSize: 16),
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
                    if (_errorMessage != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppColors.fitnessWarningColor),
                        ),
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
                            borderRadius: BorderRadius.circular(
                                16.0), // Same border radius as input fields
                          ),
                        ),
                        child: Text(
                          _isRegistering ? 'Register' : 'Login',
                          style: const TextStyle(
                              color: AppColors.fitnessPrimaryTextColor,
                              fontSize: 16),
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
                              text: _isRegistering
                                  ? 'Already have an account? '
                                  : 'Don\'t have an account? ',
                              style: const TextStyle(
                                  color: AppColors.fitnessMainColor),
                            ),
                            TextSpan(
                              text: _isRegistering ? 'Login' : 'Register',
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
