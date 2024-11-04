import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class UserProfileModule extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double height;
  final double weight;
  final String email;
  final VoidCallback onLogout;

  const UserProfileModule({
    super.key,
    this.imageUrl,
    required this.name,
    required this.height,
    required this.weight,
    required this.email,
    required this.onLogout,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    onLogout();
  }

  void _showEditProfileSheet(BuildContext context) {
    final heightController = TextEditingController(text: height.toString());
    final weightController = TextEditingController(text: weight.toString());
    final emailController = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Increase the height factor as needed
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.fitnessBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0), // Add top padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                      emailController, 'Email', TextInputType.emailAddress),
                  _buildTextField(
                      heightController, 'Height (m)', TextInputType.number),
                  _buildTextField(
                      weightController, 'Weight (kg)', TextInputType.number),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Save the updated profile information
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fitnessMainColor,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.fitnessPrimaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.fitnessPrimaryTextColor,
        ),
      ),
      style: const TextStyle(
        color: AppColors
            .fitnessPrimaryTextColor, // Set the input text color to white
      ),
      keyboardType: keyboardType,
    );
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
                _buildLogoutButton(context),
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
          icon: const Icon(Icons.edit),
          color: Colors.grey,
          onPressed: () => _showEditProfileSheet(context),
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
          _buildProfileDetailText('Email: $email'),
          _buildProfileDetailText('Height: ${height.toStringAsFixed(2)} m'),
          _buildProfileDetailText('Weight: ${weight.toStringAsFixed(2)} kg'),
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

  Center _buildLogoutButton(BuildContext context) {
    return Center(
      child: CupertinoButton(
        onPressed: () => _logout(context),
        child: Container(
          width: 410,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.fitnessBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Logout",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
