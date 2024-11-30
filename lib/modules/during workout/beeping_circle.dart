import 'dart:async';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

/// This widget represents a circle that changes color every second.
/// It is used to indicate some form of activity or alert.
class BeepingCircle extends StatefulWidget {
  const BeepingCircle({super.key});

  @override
  _BeepingCircleState createState() => _BeepingCircleState();
}

class _BeepingCircleState extends State<BeepingCircle> {
  // Boolean to track the color state of the circle
  bool _isGreen = false;
  // Timer to periodically change the color
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize the timer to change color every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _isGreen = !_isGreen; // Toggle the color state
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Animation duration of 1 second
      duration: const Duration(seconds: 1),
      width: 18, // Width of the circle
      height: 18, // Height of the circle
      decoration: BoxDecoration(
        // Change color based on the state
        color: _isGreen ? const Color(0x0f05811e) : AppColors.fitnessMainColor,
        shape: BoxShape.circle, // Shape of the container
      ),
    );
  }
}