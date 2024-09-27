import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BreakTimerModule extends StatefulWidget {
  const BreakTimerModule({Key? key}) : super(key: key);

  @override
  _BreakTimerModuleState createState() => _BreakTimerModuleState();
}

class _BreakTimerModuleState extends State<BreakTimerModule> {
  int _selectedTime = 00;

  void _startTimer() {
    // Implement the timer start logic here
  }

  void _setPresetTime(int time) {
    setState(() {
      _selectedTime = time;
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _setPresetTime(05),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('5:00',
                          style: TextStyle(
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child: Text('10:00',style: TextStyle(
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setPresetTime(15),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.0),
                          child: Text('15:00',
                              style: TextStyle(
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '00:$_selectedTime:00',style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 64,
                  ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text('Start Timer'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}