import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: SizedBox(
        height: 350.0,
        child: SingleChildScrollView(
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
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
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
                          backgroundColor: _selectedButton == 0 ? CupertinoColors.white : CupertinoColors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '5:00',
                            style: TextStyle(
                              color: _selectedButton == 0 ? Colors.black : Color(0xFF8B8B8B),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(10, 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButton == 1 ? CupertinoColors.white : CupertinoColors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '10:00',
                            style: TextStyle(
                              color: _selectedButton == 1 ? Colors.black : Color(0xFF8B8B8B),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(15, 2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedButton == 2 ? CupertinoColors.white : CupertinoColors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '15:00',
                            style: TextStyle(
                              color: _selectedButton == 2 ? Colors.black : Color(0xFF8B8B8B),
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
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                    ),
                  )),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Start Timer',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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