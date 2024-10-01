import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/logic/workout.dart';

class UpcomingWorkoutsList {
  UpcomingWorkoutsList();

  List<UpcomingWorkoutsBox> workoutList = [];

  List<UpcomingWorkoutsBox> get listOfWorkouts {
    return workoutList;
  }

  void addToList(UpcomingWorkoutsBox workout) {
    workoutList.add(workout);
  }
}
