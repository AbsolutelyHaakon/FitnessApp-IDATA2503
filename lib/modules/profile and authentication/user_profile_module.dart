import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/settings.dart';

class UserProfileModule extends StatelessWidget {
  final String? imageUrl;
  final User user;
  final VoidCallback onLogout;

  const UserProfileModule({
    super.key,
    this.imageUrl,
    required this.user,
    required this.onLogout,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF262626),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 20),
                _buildProfileDetails(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildProfileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              backgroundColor: AppColors.fitnessPrimaryTextColor,
              child: imageUrl == null
                  ? const Icon(Icons.person,
                      size: 50, color: AppColors.fitnessMainColor)
                  : null,
            ),
            const SizedBox(width: 10),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.fitnessMainColor),
          color: Colors.grey,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(onLogout: onLogout)),
            );
          },
        ),
      ],
    );
  }

  Padding _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Implement height and weight attributes for the user
          // _buildProfileDetailText('Email: $email'),
          // _buildProfileDetailText('Height: ${user.height.toStringAsFixed(2)} m'),
          // _buildProfileDetailText('Weight: ${weight.toStringAsFixed(2)} kg'),
          _buildProfileDetailText('Email: ${user.email}'),
          _buildProfileDetailText('Height: 170cm'),
          _buildProfileDetailText('Weight: 90 kg'),
        ],
      ),
    );
  }

  Text _buildProfileDetailText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}