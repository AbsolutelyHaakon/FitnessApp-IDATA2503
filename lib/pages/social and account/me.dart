import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:fitnessapp_idata2503/modules/floating_button_component.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/weight_bar_chart.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/user_profile_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';

import '../../database/Initialization/get_data_from_server.dart';
import '../../modules/profile and authentication/login_module.dart';

class Me extends StatefulWidget {
  const Me({super.key});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserDao _userDao = UserDao();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onLoginSuccess(User? user) {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
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
      appBar: PreferredSize(
        preferredSize: ui.Size.fromHeight(40.0), // Adjust the height as needed
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.fitnessModuleColor, // Set the border color
                width: 1.0, // Adjust the border width as needed
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
                    style: Theme.of(context).textTheme.bodyLarge,
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
                              const SizedBox(height: 20),
                              ProfilePage(
                                userId: FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ] else ...[
                              LoginModule(
                                formKey: _formKey,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                userDao: _userDao,
                                onLoginSuccess: _onLoginSuccess,
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
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}