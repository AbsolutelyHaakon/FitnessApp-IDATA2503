library fitnessApp.globals;

import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

ValueNotifier<bool> hasActiveWorkout = ValueNotifier<bool>(false);
ValueNotifier<String> activeWorkoutId = ValueNotifier<String>('');
ValueNotifier<String> activeWorkoutName = ValueNotifier<String>('');

int activeWorkoutIndex = 0;

List<String> officialFilterCategories = ['All', 'Starred', 'Legs', 'Abs', 'Upper Body', 'Cardio', 'Outdoors'];
List<String> officialWorkoutCategories = ['Legs', 'Abs', 'Upper Body', 'Cardio', 'Outdoors'];

List<SvgPicture> officialFilterCategoryIcons = [
  SvgPicture.asset('assets/icons/allIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/starIcon.svg', width: 25, height: 25),
  SvgPicture.asset('assets/icons/lowerBodyIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/absIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/upperBodyIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/runnerIcon.svg', width: 40, height: 40),
  SvgPicture.asset('assets/icons/hikerIcon.svg', width: 40, height: 40),
];
