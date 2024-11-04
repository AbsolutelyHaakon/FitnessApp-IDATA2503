import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';

class UpcomingWorkoutsList {
  UpcomingWorkoutsList();

  List<UpcomingWorkoutsBox> _workoutList = [];

  List<UpcomingWorkoutsBox> get listOfWorkouts {
    return _workoutList;
  }

  void addToList(UpcomingWorkoutsBox workout) {
    _workoutList.add(workout);
  }

  void insertList(List<UpcomingWorkoutsBox> list) {
    _workoutList = list;
  }
}
