import 'dart:ui' as ui;

import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/user_profile_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';

import '../../modules/profile and authentication/login_module.dart';

class Me extends StatefulWidget {
  const Me({super.key});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Form key for login form
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input
  final UserDao _userDao = UserDao(); // Data access object for user operations
  User? _currentUser; // Current logged-in user

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get the current user from Firebase
  }

  void _onLoginSuccess(User? user) {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser; // Update the current user on login success
    });
  }

  void _onLogout() {
    setState(() {
      _currentUser = null; // Clear the current user on logout
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: ui.Size.fromHeight(40.0), // Set the height of the app bar
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.fitnessModuleColor, // Border color
                width: 1.0, // Border width
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Me',
                    style: Theme.of(context).textTheme.bodyLarge, // App bar title
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    color: AppColors.fitnessBackgroundColor, // Background color
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (_currentUser != null) ...[
                              UserProfileModule(
                                user: _currentUser!, // Pass the current user to the profile module
                                onLogout: _onLogout, // Logout callback
                              ),
                              const SizedBox(height: 20),
                              ProfilePage(
                                userId: FirebaseAuth.instance.currentUser!.uid, // Pass the user ID to the profile page
                              ),
                            ] else ...[
                              LoginModule(
                                formKey: _formKey, // Pass the form key to the login module
                                emailController: _emailController, // Pass the email controller
                                passwordController: _passwordController, // Pass the password controller
                                userDao: _userDao, // Pass the user DAO
                                onLoginSuccess: _onLoginSuccess, // Login success callback
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor, // Scaffold background color
    );
  }
}