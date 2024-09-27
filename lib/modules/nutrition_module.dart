// lib/modules/nutrition_module.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NutritionModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Define the action when the button is pressed
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dining_rounded,
                color: Color(0xFF48CC6D),
                size: 100,
              ),
              Text(
                'Nutrition',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}