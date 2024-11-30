import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

// This widget creates a floating action button that toggles options
class ToggleOptionsButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ToggleOptionsButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _ToggleOptionsButtonState createState() => _ToggleOptionsButtonState();
}

class _ToggleOptionsButtonState extends State<ToggleOptionsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _addIconController; // Controller for the animation
  late Animation<double> _addIconAnimation; // Animation for rotating the icon

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a duration of 300 milliseconds
    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Define the animation to rotate the icon from 0 to 0.25 turns
    _addIconAnimation =
        Tween<double>(begin: 0, end: 0.25).animate(_addIconController);
  }

  @override
  void dispose() {
    _addIconController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  // Function to spin the button and call the onPressed callback
  void _spinButton() {
    if (_addIconController.isCompleted) {
      _addIconController.reverse(); // Reverse the animation if it's completed
    } else {
      _addIconController.forward(); // Forward the animation if it's not completed
    }
    widget.onPressed(); // Call the onPressed callback
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggleOptions', // Unique tag for the hero animation
      backgroundColor: AppColors.fitnessMainColor, // Background color of the button
      shape: const CircleBorder(), // Shape of the button
      onPressed: _spinButton, // Call the _spinButton function when pressed
      child: AnimatedBuilder(
        animation: _addIconAnimation, // Use the animation defined earlier
        child: const Icon(Icons.add, color: AppColors.fitnessBackgroundColor), // Icon to display
        builder: (context, child) {
          return Transform.rotate(
            angle: _addIconAnimation.value * 3.14159, // Rotate the icon based on the animation value
            child: child,
          );
        },
      ),
    );
  }
}