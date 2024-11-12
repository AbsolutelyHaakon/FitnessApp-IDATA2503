import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/user_profile_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';

import '../../database/Initialization/get_data_from_server.dart';
import '../../modules/profile and authentication/login_module.dart';

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
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              color: AppColors.fitnessBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (_currentUser != null) ...[
                        UserProfileModule(
                          user: _currentUser!,
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
          ),
        ),
      ],
    ),
    backgroundColor: AppColors.fitnessBackgroundColor,
  );
}
}