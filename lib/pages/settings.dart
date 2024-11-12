import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/Initialization/get_data_from_server.dart';

class SettingsPage extends StatelessWidget {
  final User? user;

  SettingsPage({Key? key, this.user}) : super(key: key);

  final GetDataFromServer _getDataFromServer = GetDataFromServer();

  // TODO: Implement proper feedback logic on the sync function
  void _synchronizeCloud(BuildContext context) async {
    try {
      await _getDataFromServer.syncData(user?.uid ?? '');
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.account_circle,
                  text: 'Account settings',
                  onTap: () {
                    // Navigate to Account settings page
                  },
                ),
                if (user?.uid == "8v56EVEYVPTXPigxMF0Hd4jNEBR2")
                  _buildSettingsItem(
                    context,
                    icon: Icons.admin_panel_settings,
                    text: 'Admin Panel',
                    onTap: () {
                      // Navigate to Admin Panel page
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
                const Spacer(),
                _buildSettingsItem(
                  context,
                  icon: Icons.privacy_tip,
                  text: 'Data and Privacy',
                  onTap: () {
                    // Navigate to Data and Privacy page
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
                    // Navigate to About us page
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.logout,
                  text: 'Log out',
                  onTap: () {
                    // Log out
                  },
                ),
              ],
            ),
          ),
        ],
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
