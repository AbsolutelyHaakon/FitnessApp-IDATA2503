import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

// The BreakTimerModule widget allows for counting down time
// Used for taking breaks between gym sets
// Last Edited: 27/09/2024
// Last Edited by: Haakon

// Explainer: As soon as we are able to implement persistent storage we should start working on the TODOs
// Persistent storage of timer presets should be cloud saved for the user to access on any device
// The countdown should only be persistent across the application and can be done before cloud storage is implemented
// TODO: Implement persistent storage for the timer presets and timer countdown
// TODO: Implement the edit functionality for the timer presets
// TODO: Potentially give the user the ability to use the timer for any amount of time as a swatch

class BreakTimerModule extends StatefulWidget {
  const BreakTimerModule({Key? key}) : super(key: key);

  @override
  _BreakTimerModuleState createState() => _BreakTimerModuleState();
}

class _BreakTimerModuleState extends State<BreakTimerModule> {
  int _selectedTime = 0; // Selected time in minutes
  int _previousSelectedTime = 0; // Previous selected time
  int _selectedButton = -1; // Index of the selected button

  Timer? _timer; // Timer object
  int remainingSeconds = 0; // Remaining seconds for the timer
  final time = '00:00:00'.obs; // Observable for the timer display
  bool isRunning = false; // Boolean to check if the timer is running

  // Method to start or stop the timer
  void _startTimer() {
    if (_selectedTime == 0) {
      return; // Do nothing if no time is selected
    }
    if (isRunning) {
      _timer?.cancel(); // Cancel the timer if it's running
      setState(() {
        isRunning = false; // Set running state to false
      });
      return;
    }
    if (remainingSeconds > 0 && _selectedTime == _previousSelectedTime) {
      setState(() {
        isRunning = true; // Set running state to true
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--; // Decrease remaining seconds
            time.value = '00:${(remainingSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';
          } else {
            timer.cancel(); // Cancel the timer when it reaches zero
            isRunning = false; // Set running state to false
          }
        });
      });
      return;
    }
    _previousSelectedTime = _selectedTime; // Update previous selected time
    remainingSeconds = _selectedTime * 60; // Convert selected time to seconds
    isRunning = true; // Set running state to true
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--; // Decrease remaining seconds
          time.value = '00:${(remainingSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';
        } else {
          timer.cancel(); // Cancel the timer when it reaches zero
          isRunning = false; // Set running state to false
        }
      });
    });
  }

  // Method to set the preset time and update the selected button
  void _setPresetTime(int newTime, int buttonIndex) {
    setState(() {
      _selectedTime = newTime; // Update selected time
      _selectedButton = buttonIndex; // Update selected button index
      if (remainingSeconds == 0) {
        time.value = '00:${newTime.toString().padLeft(2, '0')}:00'; // Update timer display
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor, // Background color
            borderRadius: BorderRadius.circular(30), // Rounded corners
            border: Border.all(
              color: AppColors.fitnessModuleColor, // Border color
              width: 1.0, // Border width
            ),
          ),
          child: Column(
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Break Timer',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor, // Text color
                          fontWeight: FontWeight.bold, // Bold text
                          fontSize: 24, // Font size
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.fitnessPrimaryTextColor), // Edit icon
                      onPressed: () {
                        // Implement the edit action here
                      },
                    ),
                  ],
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _setPresetTime(3, 0), // Set time to 3 minutes
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButton == 0 ? AppColors.fitnessPrimaryTextColor : AppColors.fitnessBackgroundColor, // Button color
                        ),
                          child: Text(
                            '3:00',
                            style: TextStyle(
                              color: _selectedButton == 0 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor, // Text color
                              fontWeight: FontWeight.bold, // Bold text
                              fontSize: 20, // Font size
                            ),
                          ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(5, 1), // Set time to 5 minutes
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButton == 1 ? AppColors.fitnessPrimaryTextColor : AppColors.fitnessBackgroundColor, // Button color
                        ),
                          child: Text(
                            '5:00',
                            style: TextStyle(
                              color: _selectedButton == 1 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor, // Text color
                              fontWeight: FontWeight.bold, // Bold text
                              fontSize: 20, // Font size
                            ),
                          ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(8, 2), // Set time to 8 minutes
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButton == 2 ? AppColors.fitnessPrimaryTextColor: AppColors.fitnessBackgroundColor, // Button color
                        ),
                          child: Text(
                            '8:00',
                            style: TextStyle(
                              color: _selectedButton == 2 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor, // Text color
                              fontWeight: FontWeight.bold, // Bold text
                              fontSize: 20, // Font size
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20), // Space between buttons and timer
                  Obx(() => Text(
                    time.value, // Display the timer
                    style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor, // Text color
                      fontWeight: FontWeight.bold, // Bold text
                      fontSize: 64, // Font size
                    ),
                  )),
                  Container(
                    width: double.infinity, // Full width button
                    child: CupertinoButton(
                      onPressed: () { _startTimer(); }, // Start or stop the timer
                      child: Container(
                        height: 60, // Button height
                        decoration: BoxDecoration(
                          color: AppColors.fitnessBackgroundColor, // Button background color
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        alignment: Alignment.center, // Center the text
                        child:  Text(isRunning ? "Stop Timer" : "Start Timer" , // Button text
                          textAlign: TextAlign.center, // Center the text
                          style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor, // Text color
                            fontWeight: FontWeight.bold, // Bold text
                            fontSize: 20, // Font size
                          ),
                        ),
                      ),
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