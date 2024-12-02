import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// About Us page to display information about the developers
class AboutUsPage extends StatelessWidget {
  // List of developers with their details
  final List<Map<String, String>> developers = [
    {
      'name': 'Adrian Faustino Johansen',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/adrian.png'
    },
    {
      'name': 'Håkon Svensen Karlsen',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/haakon.png'
    },
    {
      'name': 'Di Xie',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/di.png'
    },
    {
      'name': 'Matti Kjellstadli',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/matti.png'
    },
  ];

  AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.fitnessBackgroundColor,
        centerTitle: true, // Center the title
        title: const Text(
          'Developers',
          style: TextStyle(
            fontSize: 30, // Title font size
            fontWeight: FontWeight.w900, // Title font weight
            color: AppColors.fitnessPrimaryTextColor, // Title color
          ),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor, // App bar background color
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor), // Back button icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body
        child: Column(
          children: [
            const SizedBox(height: 20), // Space at the top
            Expanded(
              child: ListView.builder(
                itemCount: developers.length, // Number of developers
                itemBuilder: (context, index) {
                  final developer = developers[index]; // Get developer details
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0), // Padding around each developer
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50, // Avatar radius
                          backgroundImage: AssetImage(developer['imageUrl']!), // Developer image
                          backgroundColor: AppColors.fitnessMainColor, // Background color
                        ),
                        const SizedBox(height: 10), // Space between avatar and name
                        Text(
                          developer['name']!, // Developer name
                          style: const TextStyle(
                            fontSize: 20, // Name font size
                            fontWeight: FontWeight.bold, // Name font weight
                          ),
                        ),
                        const SizedBox(height: 5), // Space between name and credentials
                        Text(
                          developer['credentials']!, // Developer credentials
                          style: const TextStyle(
                            fontSize: 14, // Credentials font size
                            fontWeight: FontWeight.w500, // Credentials font weight
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor, // Background color of the page
    );
  }
}