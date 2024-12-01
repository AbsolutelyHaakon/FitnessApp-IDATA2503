import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

// This widget creates a floating action button that toggles options
class ToggleOptionsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Animation<double> animation;

  const ToggleOptionsButton({
    super.key,
    required this.onPressed,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggleOptions',
      backgroundColor: AppColors.fitnessMainColor,
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: animation.value * 3.14159,
            child:
                const Icon(Icons.add, color: AppColors.fitnessBackgroundColor),
          );
        },
      ),
    );
  }
}
