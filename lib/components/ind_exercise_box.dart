import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndExerciseBox extends StatefulWidget {
  IndExerciseBox({
    Key? key,
    required this.exerciseId,
    required this.exerciseName,
    required this.repsController,
    required this.setsController,
  }) : super(key: key);

  final String exerciseId;
  final String exerciseName;
  final TextEditingController repsController;
  final TextEditingController setsController;

  @override
  _IndExerciseBoxState createState() => _IndExerciseBoxState();
}

class _IndExerciseBoxState extends State<IndExerciseBox> {
  int _selectedReps = 12; // Default value for reps
  int _selectedSets = 3; // Default value for sets

  @override
  void initState() {
    super.initState();
    widget.repsController.text = _selectedReps.toString();
    widget.setsController.text = _selectedSets.toString();
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: AppColors.fitnessModuleColor,
          child: Column(
            children: [
              const SizedBox(height: 20),
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
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedReps = index + 1;
                            widget.repsController.text = _selectedReps.toString();
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
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _selectedSets = index + 1;
                            widget.setsController.text = _selectedSets.toString();
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
      onTap: () => _showPicker(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.fitnessModuleColor,
          borderRadius: BorderRadius.circular(10), // Add rounded corners
        ),
        height: 80,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 15),
                const Icon(
                  Icons.menu,
                  color: AppColors.fitnessPrimaryTextColor,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.exerciseName,
                    style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Reps',
                      style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                    Text(
                      _selectedReps.toString(),
                      style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sets',
                      style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                    Text(
                      _selectedSets.toString(),
                      style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
              ],
            ),
            Positioned(
              top: 5,
              left: 10,
              child: Text(
                'Click to Edit',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}