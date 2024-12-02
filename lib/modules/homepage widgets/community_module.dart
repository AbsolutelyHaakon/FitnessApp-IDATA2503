import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../pages/social and account/social_feed.dart';

// This widget represents the Community Module on the home screen
// It contains an icon and a text label, and navigates to the Social Feed page when pressed
class CommunityModule extends StatelessWidget {
  const CommunityModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Navigate to the Social Feed page when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SocialFeed()),
          );
        },
        child: Container(
          width: 180, // Set the width of the container
          height: 180, // Set the height of the container
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor, // Set the background color
            borderRadius: BorderRadius.circular(30), // Set the border radius
          ),
          child: const Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the children vertically
            children: [
              Icon(
                Icons.people_rounded, // Use the people icon
                color: AppColors.fitnessMainColor, // Set the icon color
                size: 100, // Set the icon size
              ),
              Text(
                'Community', // Set the text label
                style: TextStyle(
                  color:
                      AppColors.fitnessPrimaryTextColor, // Set the text color
                  fontWeight: FontWeight.w500, // Set the text weight
                  fontSize: 20, // Set the text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
