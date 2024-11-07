import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class DwProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 10.0, right: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Progress',
            style: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounded corners
            child: const LinearProgressIndicator(
              value: 0.3,
              backgroundColor: AppColors.fitnessBackgroundColor, // Dark grey background
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.fitnessMainColor), // Green color
              minHeight: 30, // Thicker progress bar
            ),
          ),
        ],
      ),
    );
  }
}