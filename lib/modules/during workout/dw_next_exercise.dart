import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

// This widget shows the details of the next exercise in the workout plan
// It displays the exercise name, sets, reps, and weight
class DwNextExercise extends StatefulWidget {
  const DwNextExercise({super.key});

  @override
  _DwNextExerciseState createState() => _DwNextExerciseState();
}

class _DwNextExerciseState extends State<DwNextExercise> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Container(
              width: 400, // Width of the container
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor, // Background color
                borderRadius: BorderRadius.circular(30), // Rounded corners
                border: Border.all(
                  color: Color(0xFF262626), // Border color
                  width: 1.0, // Border width
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                children: [
                  const SizedBox(height: 20), // Space at the top
                  Row(
                    children: [
                      const SizedBox(width: 20), // Space on the left
                      Container(
                        width: 20, // Width of the circle
                        height: 20, // Height of the circle
                        decoration: const BoxDecoration(
                          color: Colors.grey, // Circle color
                          shape: BoxShape.circle, // Circle shape
                        ),
                      ),
                      const SizedBox(width: 10), // Space between circle and text
                      const Text(
                        'Next Exercise', // Title text
                        style: TextStyle(
                          color: Colors.grey, // Text color
                          fontSize: 20, // Text size
                          fontWeight: FontWeight.bold, // Text weight
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      SizedBox(width: 50), // Space on the left
                      Text(
                        'Pushups', // Exercise name
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 30, // Text size
                          fontWeight: FontWeight.w900, // Text weight
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 50.0), // Space on the left
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
                          children: [
                            Text(
                              'Sets   4', // Number of sets
                              style: TextStyle(
                                color: Colors.grey, // Text color
                                fontWeight: FontWeight.bold, // Text weight
                                fontSize: 15, // Text size
                              ),
                            ),
                            Text(
                              'Reps  10', // Number of reps
                              style: TextStyle(
                                color: Colors.grey, // Text color
                                fontWeight: FontWeight.bold, // Text weight
                                fontSize: 15, // Text size
                              ),
                            ),
                            Text(
                              'Weight  0', // Weight
                              style: TextStyle(
                                color: Colors.grey, // Text color
                                fontWeight: FontWeight.bold, // Text weight
                                fontSize: 15, // Text size
                              ),
                            ),
                            const SizedBox(height: 10), // Space at the bottom
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}