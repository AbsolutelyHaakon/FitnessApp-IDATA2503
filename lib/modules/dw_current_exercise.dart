import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

// Shows the selected workout plan details before deciding to start it
// Displays workout info and potentially a map of the workout route

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

//TODO: Implement map fucntionality
//TODO: Connect it to the persistent storage

class DwCurrentExercise extends StatefulWidget {
  const DwCurrentExercise({super.key});

  @override
  _DwCurrentExerciseState createState() => _DwCurrentExerciseState();
}

class _DwCurrentExerciseState extends State<DwCurrentExercise> {
  bool _isAddingSet = false;
  int _reps = 0;
  int _weight = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          IntrinsicHeight(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color(0xFF262626), // Almost the same color
                  width: 1.0, // Very thin
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF48CC6D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Pushups',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sets   4',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Reps  10',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Weight  0',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _isAddingSet,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Reps:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 100,
                                  child: CupertinoPicker(
                                    itemExtent: 40.0,
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _reps = index;
                                      });
                                    },
                                    children: List<Widget>.generate(50, (int index) {
                                      return Center(
                                        child: Text(
                                          index.toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Weight:',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 100,
                                  child: CupertinoPicker(
                                    itemExtent: 40.0,
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _weight = index * 5;
                                      });
                                    },
                                    children: List<Widget>.generate(50, (int index) {
                                      return Center(
                                        child: Text(
                                          (index * 5).toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        _isAddingSet = !_isAddingSet;
                      });
                    },
                    child: Container(
                      width: 410,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Add Set",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {},
                    child: Container(
                      width: 410,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF48CC6D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Finish Exercise",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}