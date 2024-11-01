import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AddWorkout extends StatefulWidget {
  const AddWorkout({super.key});

  @override
  State<AddWorkout> createState() {
    return _AddWorkoutState();
  }
}

class _AddWorkoutState extends State<AddWorkout> {
  final _titleController = TextEditingController();
  Type _selectedCategory = Type.other;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
            controller: _titleController,
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.fitnessMainColor,
                ),
              ),
              label: Text(
                'Workout Title',
                style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DropdownButton(
                  style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  dropdownColor: const Color.fromARGB(255, 36, 36, 36),
                  value: _selectedCategory,
                  items: Type.values
                      .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.name.toUpperCase(),
                          )))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCategory = value;
                    });
                  }),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
