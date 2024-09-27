import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BreakTimerModule extends StatefulWidget {
  const BreakTimerModule({Key? key}) : super(key: key);

  @override
  _BreakTimerModuleState createState() => _BreakTimerModuleState();
}

class _BreakTimerModuleState extends State<BreakTimerModule> {
  int _selectedTime = 0;
  int _selectedButton = -1;

  void _startTimer() {
    // Implement the timer start logic here
  }

  void _setPresetTime(int time, int buttonIndex) {
    setState(() {
      _selectedTime = time;
      _selectedButton = buttonIndex;
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
                  Text(
                    '00:${_selectedTime.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                    ),
                  ),
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