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
  int _selectedSets = 3;// Default value for sets
  bool _isRepsFocused = false;
  bool _isSetsFocused = false;
  final FocusNode _repsFocusNode = FocusNode();
  final FocusNode _setsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _repsFocusNode.addListener(() {
      setState(() {
        _isRepsFocused = _repsFocusNode.hasFocus;
      });
    });
    _setsFocusNode.addListener(() {
      setState(() {
        _isSetsFocused = _setsFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _repsFocusNode.dispose();
    _setsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.fitnessModuleColor,
        borderRadius: BorderRadius.circular(10), // Add rounded corners
      ),
      height: 80,
      child: Row(
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isRepsFocused ? 100 : 32,
                width: 50,
                child: Focus(
                  focusNode: _repsFocusNode,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSetsFocused ? 100 : 32,
                width: 50,
                child: Focus(
                  focusNode: _setsFocusNode,
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
              ),
            ],
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}