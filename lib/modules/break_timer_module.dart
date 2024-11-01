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
  int _selectedTime = 0;
  int _previousSelectedTime = 0;
  int _selectedButton = -1;

  Timer? _timer;
  int remainingSeconds = 0;
  final time = '00:00:00'.obs;
  bool isRunning = false;

  void _startTimer() {
    if (_selectedTime == 0) {
      return;
    }
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
      return;
    }
    if (remainingSeconds > 0 && _selectedTime == _previousSelectedTime) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
            time.value = '00:${(remainingSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';
          } else {
            timer.cancel();
            isRunning = false;
          }
        });
      });
      return;
    }
    _previousSelectedTime = _selectedTime;
    remainingSeconds = _selectedTime * 60;
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          time.value = '00:${(remainingSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';
        } else {
          timer.cancel();
          isRunning = false;
        }
      });
    });
  }

  void _setPresetTime(int newTime, int buttonIndex) {
    setState(() {
      _selectedTime = newTime;
      _selectedButton = buttonIndex;
      if (remainingSeconds == 0) {
        time.value = '00:${newTime.toString().padLeft(2, '0')}:00';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Break Timer',
                          style: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.fitnessPrimaryTextColor),
                        onPressed: () {
                          // Implement the edit action here
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _setPresetTime(5, 0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedButton == 0 ? AppColors.fitnessPrimaryTextColor : AppColors.fitnessBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '5:00',
                              style: TextStyle(
                                color: _selectedButton == 0 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _setPresetTime(10, 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedButton == 1 ? AppColors.fitnessPrimaryTextColor : AppColors.fitnessBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '10:00',
                              style: TextStyle(
                                color: _selectedButton == 1 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _setPresetTime(15, 2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedButton == 2 ? AppColors.fitnessPrimaryTextColor: AppColors.fitnessBackgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '15:00',
                              style: TextStyle(
                                color: _selectedButton == 2 ? AppColors.fitnessBackgroundColor : AppColors.fitnessSecondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() => Text(
                      time.value,
                      style: const TextStyle(
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 64,
                      ),
                    )),
                    Container(
                      width: double.infinity,
                      child: CupertinoButton(
                        onPressed: () { _startTimer(); },
                        child: Container(
                          width: 400,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.fitnessBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,

                          child: const Text("Start Timer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.fitnessPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
      ),
    );
  }
}