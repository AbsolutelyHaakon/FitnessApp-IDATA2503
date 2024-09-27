// lib/modules/nutrition_module.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodayModule extends StatelessWidget {
  const TodayModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Define the action when the button is pressed
        },
        child: Container(
          width: 410,
          height: 200,
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            CupertinoIcons.calendar_today,
            color: CupertinoColors.white,
            size: 100,
          ),
        ),
      ),

    );
  }
}