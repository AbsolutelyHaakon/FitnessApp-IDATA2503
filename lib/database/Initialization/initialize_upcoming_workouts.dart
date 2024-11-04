import '../../components/upcoming_workouts_box.dart';
import '../crud/user_workouts_dao.dart';
import '../crud/workout_dao.dart';
import '../tables/user_workouts.dart';
import '../tables/workout.dart';

Future<List<UpcomingWorkoutsBox>> initializeWorkoutData(String userId) async {
  UserWorkoutsDao userWorkoutsDao = UserWorkoutsDao();
  WorkoutDao workoutDao = WorkoutDao();

  List<UserWorkouts> userWorkouts = await userWorkoutsDao.fetchByUserId(userId);

  List<UpcomingWorkoutsBox> workouts = [];
  for (var userWorkout in userWorkouts) {
    Workouts workout = await workoutDao.fetchById(userWorkout.workoutId);

    workouts.add(UpcomingWorkoutsBox(
      title: workout.name,
      category: workout.category ?? 'No category',
      date: userWorkout.date,
    ));
  }

  return workouts;
}