import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/components/ind_exercise_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final FocusNode _descriptionFocusNode = FocusNode();
  bool _isDescriptionFocused = false;

  List<IndExerciseBox> exercises = [
    IndExerciseBox(
      key: ValueKey('exercise1'),
      exerciseName: "Farty",
      exerciseReps: 10,
      exerciseSets: 3,
    ),
    IndExerciseBox(
      key: ValueKey('exercise2'),
      exerciseName: "Push Up",
      exerciseReps: 15,
      exerciseSets: 4,
    ),
    IndExerciseBox(
      key: ValueKey('exercise3'),
      exerciseName: "Squat",
      exerciseReps: 20,
      exerciseSets: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fitnessPrimaryTextColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fitnessBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Workout Title..',
                  hintStyle: const TextStyle(
                    color: AppColors.fitnessSecondaryTextColor,
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isDescriptionFocused
                  ? MediaQuery.of(context).size.height - 200
                  : 60,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                focusNode: _descriptionFocusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fitnessPrimaryTextColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fitnessBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Description..',
                  hintStyle: const TextStyle(
                    color: AppColors.fitnessSecondaryTextColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ReorderableListView(
                proxyDecorator:
                    (Widget child, int index, Animation<double> animation) {
                  return Transform.scale(
                    scale: 1.05,
                    child: Material(
                      child: child,
                      color: Colors.transparent,
                      shadowColor:
                          AppColors.fitnessBackgroundColor.withOpacity(0.3),
                      elevation: 6,
                    ),
                  );
                },
                scrollDirection: Axis.vertical,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = exercises.removeAt(oldIndex);
                    exercises.insert(newIndex, item);
                  });
                },
                children: exercises,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 30),
          Expanded(
            child: FloatingActionButton(
              heroTag: "create",
              onPressed: () {},
              child: Text("Create Workout"),
              backgroundColor: AppColors.fitnessMainColor,
            ),
          ),
          SizedBox(width: 15),
          FloatingActionButton(
            heroTag: "add",
            onPressed: () {},
            child: Icon(Icons.add),
            backgroundColor: AppColors.fitnessMainColor,
          ),
        ],
      ),
    );
  }
}
