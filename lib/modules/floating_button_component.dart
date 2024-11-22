import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

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
  late AnimationController _addIconController;
  late Animation<double> _addIconAnimation;

  @override
  void initState() {
    super.initState();
    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addIconAnimation =
        Tween<double>(begin: 0, end: 0.25).animate(_addIconController);
  }

  @override
  void dispose() {
    _addIconController.dispose();
    super.dispose();
  }

  void _spinButton() {
    if (_addIconController.isCompleted) {
      _addIconController.reverse();
    } else {
      _addIconController.forward();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggleOptions',
      backgroundColor: AppColors.fitnessMainColor,
      shape: const CircleBorder(),
      onPressed: _spinButton,
      child: AnimatedBuilder(
        animation: _addIconAnimation,
        child: const Icon(Icons.add, color: Colors.black),
        builder: (context, child) {
          return Transform.rotate(
            angle: _addIconAnimation.value * 3.14159,
            child: child,
          );
        },
      ),
    );
  }
}