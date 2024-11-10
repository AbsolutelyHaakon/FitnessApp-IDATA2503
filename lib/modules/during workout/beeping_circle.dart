import 'dart:async';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class BeepingCircle extends StatefulWidget {
  @override
  _BeepingCircleState createState() => _BeepingCircleState();
}

class _BeepingCircleState extends State<BeepingCircle> {
  bool _isGreen = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _isGreen = !_isGreen;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: _isGreen ? const Color(0xF05811E) : AppColors.fitnessMainColor,
        shape: BoxShape.circle,
      ),
    );
  }
}