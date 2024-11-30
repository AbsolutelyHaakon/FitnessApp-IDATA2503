import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/about_us.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/account_settings.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/admin_panel.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/data_and_privacy_page.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/route_planner.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../database/Initialization/get_data_from_server.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onLogout;

  SettingsPage({super.key, this.onLogout});

  final GetDataFromServer _getDataFromServer = GetDataFromServer();
  final UserDao _userDao = UserDao();

  // Function to synchronize data with the cloud
  void _synchronizeCloud(BuildContext context) async {
    try {
      await _getDataFromServer
          .syncData(FirebaseAuth.instance.currentUser?.uid ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: AppColors.fitnessPrimaryTextColor),
              SizedBox(width: 8),
              Text('Sync completed'),
            ],
          ),
          backgroundColor: AppColors.fitnessMainColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }
  }

  // Function to log out the user
  Future<void> _logout() async {
    // Set all local workouts and user workouts to inactive when logging out to prevent data from being displayed
    hasActiveWorkout.value = false;
    activeUserWorkoutId.value = '';
    activeWorkoutId.value = '';
    activeWorkoutName.value = '';

    final WorkoutDao _workoutDao = WorkoutDao();
    final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
    await _workoutDao.localSetAllInactive();
    await _userWorkoutsDao.localSetAllInactive();

    // Sign out of Firebase
    await FirebaseAuth.instance.signOut();
    onLogout?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<bool>(
        future: _userDao.getAdminStatus(FirebaseAuth.instance.currentUser?.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final isAdmin = snapshot.data ?? false;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _buildSettingsItem(
                        context,
                        icon: Icons.account_circle,
                        text: 'Account Settings & Goals',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccountSettingsPage(),
                            ),
                          );
                        },
                      ),
                      if (isAdmin)
                        _buildSettingsItem(
                          context,
                          icon: Icons.admin_panel_settings,
                          text: 'Admin Panel',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminPanel()),
                            );
                          },
                        ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.sync,
                        text: 'Synchronize Cloud',
                        onTap: () {
                          _synchronizeCloud(context);
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.privacy_tip,
                        text: 'Data and Privacy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataAndPrivacyPage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.description,
                        text: 'Terms and Conditions',
                        onTap: () {
                          // Navigate to Terms and Conditions page
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.info,
                        text: 'About us',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutUsPage()),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.logout,
                        text: 'Log out',
                        onTap: () {
                          _logout();
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildSettingsItem(
                        context,
                        icon: Icons.map,
                        text: 'Map',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoutePlanner()),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.fitnessMainColor),
      title: Text(text,
          style: const TextStyle(
              color: AppColors.fitnessPrimaryTextColor, fontSize: 18)),
      trailing: text != 'Synchronize Cloud' && text != 'Log out'
          ? Transform.scale(
              scale: 0.6,
              child: const Icon(CupertinoIcons.right_chevron,
                  color: AppColors.fitnessMainColor),
            )
          : null,
      onTap: onTap,
    );
  }
}
