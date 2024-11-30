import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// This widget represents an individual exercise box
class IndExerciseBox extends StatefulWidget {
  const IndExerciseBox({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.repsController,
    required this.setsController,
  }) : super(key: key);

  final String exerciseId; // ID of the exercise
  final String exerciseName; // Name of the exercise
  final TextEditingController repsController; // Controller for reps input
  final TextEditingController setsController; // Controller for sets input

  @override
  _IndExerciseBoxState createState() => _IndExerciseBoxState();
}

class _IndExerciseBoxState extends State<IndExerciseBox> {
  int _selectedReps = 12; // Default value for reps
  int _selectedSets = 3; // Default value for sets

  @override
  void initState() {
    super.initState();
    widget.repsController.text = _selectedReps.toString(); // Initialize reps controller
    widget.setsController.text = _selectedSets.toString(); // Initialize sets controller
  }

  // Function to show the picker for selecting reps and sets
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Height of the bottom sheet
          color: AppColors.fitnessModuleColor, // Background color
          child: Column(
            children: [
              const SizedBox(height: 20), // Spacer
              const Text(
                'Select Reps and Sets',
                style: TextStyle(color: AppColors.fitnessPrimaryTextColor, fontSize: 18),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: _selectedReps - 1),
                        itemExtent: 32.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedReps = index + 1; // Update selected reps
                            widget.repsController.text = _selectedReps.toString(); // Update controller
                          });
                        },
                        children: List<Widget>.generate(20, (int index) {
                          return Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: _selectedSets - 1),
                        itemExtent: 32.0, // Height of each item
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedSets = index + 1; // Update selected sets
                            widget.setsController.text = _selectedSets.toString(); // Update controller
                          });
                        },
                        children: List<Widget>.generate(20, (int index) {
                          return Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context), // Show picker when tapped
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15), // Margin around the container
        decoration: BoxDecoration(
          color: AppColors.fitnessModuleColor, // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        height: 80, // Height of the container
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 15), // Spacer
                const Icon(
                  Icons.menu,
                  color: AppColors.fitnessPrimaryTextColor, // Icon color
                ),
                const SizedBox(width: 15), // Spacer
                Expanded(
                  child: Text(
                    widget.exerciseName, // Display exercise name
                    style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  ),
                ),
                const SizedBox(width: 15), // Spacer
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Reps',
                      style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                    Text(
                      _selectedReps.toString(), // Display selected reps
                      style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(width: 15), // Spacer
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sets',
                      style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                    Text(
                      _selectedSets.toString(), // Display selected sets
                      style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(width: 15), // Spacer
              ],
            ),
            Positioned(
              top: 5,
              left: 10,
              child: Text(
                'Click to Edit', // Instruction text
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}