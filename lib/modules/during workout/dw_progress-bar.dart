import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

/// This widget represents a progress bar for tracking workout progress.
/// It takes a value as a parameter to indicate the progress percentage.
class DwProgressBar extends StatefulWidget {
  final double value;

  const DwProgressBar({super.key, required this.value});

  @override
  State<DwProgressBar> createState() => _DwProgressBarState();
}

class _DwProgressBarState extends State<DwProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0), // Add padding to the left and right
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column
        children: [
          const Text(
            'Workout Progress', // Title of the progress bar
            style: TextStyle(
              color: AppColors.fitnessSecondaryTextColor, // Set the text color
              fontSize: 12, // Set the text size
            ),
          ),
          const SizedBox(height: 5), // Add some space between the title and the progress bar
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.value), // Animate the progress bar from 0 to the given value
            duration: const Duration(seconds: 1), // Set the duration of the animation
            curve: Curves.easeInOut, // Use easeInOut curve for smooth animation
            builder: (context, value, child) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Round the corners of the progress bar
                    child: LinearProgressIndicator(
                      value: value, // Set the progress value
                      backgroundColor: AppColors.fitnessSecondaryModuleColor, // Set the background color
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.fitnessMainColor), // Set the progress color
                      minHeight: 30, // Set the height of the progress bar
                    ),
                  ),
                  Positioned.fill(
                    left: 10, // Position the text 10 pixels from the left
                    top: 5, // Position the text 5 pixels from the top
                    child: Text(
                      textAlign: TextAlign.left, // Align the text to the left
                      '${(value * 100).toStringAsFixed(0)}%', // Display the progress percentage
                      style: const TextStyle(
                        color: Colors.white, // Set the text color to white
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}