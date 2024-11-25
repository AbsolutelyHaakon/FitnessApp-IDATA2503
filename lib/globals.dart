library fitnessApp.globals;

import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

ValueNotifier<bool> hasActiveWorkout = ValueNotifier<bool>(false);
ValueNotifier<String> activeUserWorkoutId = ValueNotifier<String>('');
ValueNotifier<String> activeWorkoutId = ValueNotifier<String>('');
ValueNotifier<String> activeWorkoutName = ValueNotifier<String>('');
Map<Exercises, List<SetStats>> exerciseStats = {};
int activeWorkoutIndex = 0;
DateTime activeWorkoutStartTime = DateTime.now();

List<String> officialFilterCategories = ['All', 'Starred', 'Legs', 'Core', 'Upper Body', 'Cardio', 'Outdoors'];
List<String> officialWorkoutCategories = ['Legs', 'Core', 'Upper Body', 'Cardio', 'Outdoors'];

List<SvgPicture> officialFilterCategoryIcons = [
  SvgPicture.asset('assets/icons/allIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/starIcon.svg', width: 25, height: 25),
  SvgPicture.asset('assets/icons/lowerBodyIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/coreIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/upperBodyIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/runnerIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/hikerIcon.svg', width: 40, height: 40),
];

class SetStats {
  int set;
  int reps;
  int weight;

  SetStats({required this.set, required this.reps, required this.weight});

  Map<String, dynamic> toJson() =>
      {
        'set': set,
        'reps': reps,
        'weight': weight,
      };
}
