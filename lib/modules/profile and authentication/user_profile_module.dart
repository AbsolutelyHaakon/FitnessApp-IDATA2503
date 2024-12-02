import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/settings.dart';

/// This class represents the user profile module in the fitness app.
/// It displays the user's profile information and allows them to log out.
class UserProfileModule extends StatelessWidget {
  final String? imageUrl; // URL of the user's profile image
  final User user; // Firebase user object
  final VoidCallback onLogout; // Callback function for logging out

  const UserProfileModule({
    super.key,
    this.imageUrl,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width
    return Center(
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Container(
            width: screenWidth *
                0.9, // Set the container width to 90% of the screen width
            padding: const EdgeInsets.symmetric(
                vertical: 20), // Add vertical padding
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor, // Set the background color
              borderRadius: BorderRadius.circular(30), // Add rounded corners
              border: Border.all(
                color: const Color(0xFF262626), // Set the border color
                width: 1.0, // Set the border width
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children to the start
              children: [
                _buildProfileHeader(context), // Build the profile header
                const SizedBox(height: 20), // Add some space
                FutureBuilder<Padding>(
                  future: getUserData(), // Fetch user data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show loading indicator
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show error message
                    } else if (snapshot.hasData) {
                      return snapshot.data!; // Show user data
                    } else {
                      return const Text(
                          'No data available'); // Show message if no data
                    }
                  },
                ),
                const SizedBox(height: 16), // Add some space
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the profile header with the user's profile image and settings button.
  Row _buildProfileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Space between elements
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start
      children: [
        Row(
          children: [
            const SizedBox(width: 20), // Add some space
            CircleAvatar(
              radius: 50, // Set the radius of the avatar
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : null, // Set the profile image
              backgroundColor:
                  AppColors.fitnessPrimaryTextColor, // Set the background color
              child: imageUrl == null
                  ? const Icon(Icons.person,
                      size: 50,
                      color: AppColors
                          .fitnessMainColor) // Show default icon if no image
                  : null,
            ),
            const SizedBox(width: 10), // Add some space
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings,
              color: AppColors.fitnessMainColor), // Settings icon
          color: Colors.grey, // Set the icon color
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(
                      onLogout: onLogout)), // Navigate to settings page
            );
          },
        ),
      ],
    );
  }

  /// Fetches the user data from Firebase and returns a widget displaying the data.
  Future<Padding> getUserData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userDataMap = await UserDao().fireBaseGetUserData(FirebaseAuth
          .instance.currentUser!.uid); // Fetch user data from Firebase

      if (userDataMap != null &&
          userDataMap.containsKey('weight') &&
          userDataMap.containsKey('height')) {
        var weightValue = userDataMap['weight'];
        var heightValue = userDataMap['height'];

        int weight;
        int height;

        if (weightValue is int) {
          weight = weightValue; // Convert weight to int
        } else if (weightValue is double) {
          weight = weightValue.toInt(); // Convert weight to int
        } else {
          weight = int.parse(weightValue.toString()); // Convert weight to int
        }

        if (heightValue is int) {
          height = heightValue; // Convert height to int
        } else if (heightValue is double) {
          height = heightValue.toInt(); // Convert height to int
        } else {
          height = int.parse(heightValue.toString()); // Convert height to int
        }

        return _buildProfileDetails(
            weight, height); // Build profile details widget
      }
    }
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
      child: Text(
        'No user data found', // Show message if no user data
        style: TextStyle(
          color: Colors.white70, // Set text color
          fontSize: 15, // Set text size
          fontWeight: FontWeight.bold, // Set text weight
        ),
      ),
    );
  }

  /// Builds a widget displaying the user's profile details.
  Padding _buildProfileDetails(int weight, int height) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0), // Add horizontal padding
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          _buildProfileDetailText('Email: ${user.email}'), // Show user email
          _buildProfileDetailText('Height: ${height}cm'), // Show user height
          _buildProfileDetailText('Weight: ${weight}kg'), // Show user weight
        ],
      ),
    );
  }

  /// Builds a text widget for displaying a profile detail.
  Text _buildProfileDetailText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70, // Set text color
        fontSize: 15, // Set text size
        fontWeight: FontWeight.bold, // Set text weight
      ),
    );
  }
}
