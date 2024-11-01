import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Module for displaying ring widgets as a progress bar
// Used to display progress in a certain category
// Examples: BMI, Calories, Body fat, etc.

// Last edited 27/09/2024
// Last edited by Matti Kjellstadli

//TODO: Implement the actual progress values as persistent values
//TODO: Link the values up to the actual data

class RingsModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Define the action when the button is pressed
        },
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1C),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircularProgressIndicator(
                            value: 0.75, // Example progress value
                            strokeWidth: 8.0,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.fitnessMainColor),
                            backgroundColor: AppColors.fitnessSecondaryModuleColor,
                          ),
                        ),
                        Text(
                          'KG',
                          style: TextStyle(
                            color: AppColors.fitnessMainColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircularProgressIndicator(
                            value: 0.5, // Example progress value
                            strokeWidth: 8.0,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                            backgroundColor: AppColors.fitnessSecondaryModuleColor,
                          ),
                        ),
                        Text(
                          'Cal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircularProgressIndicator(
                            value: 0.25, // Example progress value
                            strokeWidth: 8.0,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC9748)),
                            backgroundColor: AppColors.fitnessSecondaryModuleColor,
                          ),
                        ),
                        Text(
                          'Body\nFat',
                          style: TextStyle(
                            color: Color(0xFFCC9748),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircularProgressIndicator(
                            value: 1, // Example progress value
                            strokeWidth: 8.0,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC4848)),
                            backgroundColor: AppColors.fitnessSecondaryModuleColor,
                          ),
                        ),
                        Text(
                          'Cal\nBurn',
                          style: TextStyle(
                            color: Color(0xFFCC4848),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}