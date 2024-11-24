import 'dart:ffi';

import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:fitnessapp_idata2503/modules/floating_button_component.dart';
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
  late final weightController = TextEditingController();
  late final caloriesController = TextEditingController();
  late AnimationController _addIconController;
  late Animation<double> _buttonAnimation;
  User? _currentUser;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _addIconController,
      curve: Curves.easeInOut,
    );
  }

  void onSave() async {
    int weight = int.parse(weightController.text);
    DateTime date = DateTime.now();

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      await UserHealthDataDao().fireBaseCreateUserHealthData(
          FirebaseAuth.instance.currentUser!.uid,
          null,
          weight,
          date,
          null,
          null);
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  void setWeightGoal(int weight) {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      UserDao().fireBaseUpdateUserData(FirebaseAuth.instance.currentUser!.uid,
          '', 0, 0, weight.toDouble(), null, null);
    }
    setState(() {});
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

  void _toggleOptions() {
    if (!mounted) return;
    setState(() {
      _showOptions = !_showOptions;
    });
    if (_addIconController.isCompleted) {
      _addIconController.reverse();
    } else {
      _addIconController.forward();
    }
  }

  void _spinButton() {
    if (_addIconController.isCompleted) {
      _addIconController.reverse();
    } else {
      _addIconController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              WeightBarChart(),
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
          if (_showOptions) ...[
            Positioned(
              bottom: 130,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () async {
                    _toggleOptions();
                    showDialog(
                        context: context,
                        builder: (BuildContext builder) {
                          return AlertDialog(
                            backgroundColor: AppColors.fitnessModuleColor,
                            title: const Text('Insert Weight'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    cursorColor: Colors.white,
                                    controller: weightController,
                                    decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      labelStyle: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      suffixStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.fitnessMainColor),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.fitnessMainColor),
                                      ),
                                      labelText: 'Weight',
                                      hintText: 'Enter your weight',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: onSave,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fitnessMainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Add Weight',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.fitnessBackgroundColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    _toggleOptions();
                    showDialog(
                        context: context,
                        builder: (BuildContext builder) {
                          return AlertDialog(
                            backgroundColor: AppColors.fitnessModuleColor,
                            title: const Text('Set Weight Goal'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    cursorColor: Colors.white,
                                    controller: weightController,
                                    decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      labelStyle: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                      suffixStyle:
                                          TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.fitnessMainColor),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.fitnessMainColor),
                                      ),
                                      labelText: 'Weight',
                                      hintText: 'Enter your weight goal',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setWeightGoal(int.parse(
                                      weightController.text.toString()));
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fitnessMainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Set Weight Goal',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      floatingActionButton: ToggleOptionsButton(onPressed: _toggleOptions),
    );
  }
}
