// ignore_for_file: use_build_context_synchronously

import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitnessapp_idata2503/globals.dart';

import '../../database/tables/workout.dart';
import '../../styles.dart';

/// This widget represents the end workout screen.
/// It allows the user to end their current workout session.
class DwEndWorkout extends StatefulWidget {
  final Workouts workout;

  const DwEndWorkout({super.key, required this.workout});

  @override
  _DwEndWorkoutState createState() => _DwEndWorkoutState();
}

class _DwEndWorkoutState extends State<DwEndWorkout> {
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();

  /// This function ends the current workout by updating the state and database.
  Future<void> _endWorkout() async {
    hasActiveWorkout.value = false; // Set the active workout flag to false
    activeWorkoutId.value = ''; // Clear the active workout ID
    activeWorkoutName.value = ''; // Clear the active workout name
    activeWorkoutIndex = 0; // Reset the active workout index
    await _userWorkoutsDao
        .localSetAllInactive(); // Update the database to set all workouts as inactive
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Container(
              width: 400, // Set the width of the container
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor, // Set the background color
                borderRadius:
                    BorderRadius.circular(30), // Set the border radius
                border: Border.all(
                  color: const Color(0xFF262626), // Set the border color
                  width: 1.0, // Set the border width
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align children to the start
                children: [
                  CupertinoButton(
                    onPressed: () async {
                      await _endWorkout(); // Call the function to end the workout
                      Navigator.pop(
                          context); // Navigate back to the previous screen
                    },
                    child: Container(
                      width: 410, // Set the width of the button
                      height: 60, // Set the height of the button
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC4848), // Set the button color
                        borderRadius:
                            BorderRadius.circular(20), // Set the border radius
                      ),
                      alignment:
                          Alignment.center, // Center the text inside the button
                      child: const Text(
                        "End Workout", // Button text
                        textAlign: TextAlign.center, // Center the text
                        style: TextStyle(
                          color: CupertinoColors.white, // Set the text color
                          fontWeight: FontWeight.bold, // Make the text bold
                          fontSize: 20, // Set the text size
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
