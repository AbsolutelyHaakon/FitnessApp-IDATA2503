import 'package:fitnessapp_idata2503/logic/exercise.dart';

class Workout {
  Workout({
    required this.exercise,
    required this.reps,
    required this.sets,
  });

  Exercise exercise;
  int reps;
  int sets;
}
