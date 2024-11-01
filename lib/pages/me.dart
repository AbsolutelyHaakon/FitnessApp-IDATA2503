// lib/pages/me.dart
import 'package:fitnessapp_idata2503/modules/user_profile_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/modules/authentication/login_module.dart';

// Me / profile page for the app
// Contains the user profile module and login module
// If the user is logged in, the user profile module is shown
// If the user is not logged in, the login module is shown

// Last edited: 31/10/2024
// Last edited by: Håkon Svensen Karlsen
class Me extends StatefulWidget {
  final User? user;
  const Me({super.key, this.user});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserDao _userDao = UserDao();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _onLoginSuccess(User? user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _onLogout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.fitnessBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentUser != null) ...[
                  UserProfileModule(
                    name: _currentUser!.displayName ?? 'Anonymous',
                    height: 1.75, // Replace with actual height
                    weight: 70.0, // Replace with actual weight
                    email: _currentUser!.email ?? 'No email',
                    onLogout: _onLogout,
                  ),
                ] else ...[
                  LoginModule(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    userDao: _userDao,
                    onLoginSuccess: _onLoginSuccess,
                    user: _currentUser,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}