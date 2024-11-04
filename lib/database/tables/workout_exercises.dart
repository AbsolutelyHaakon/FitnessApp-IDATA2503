class WorkoutExercises {
  final String workoutExercisesId;
  final String workoutId;
  final String exerciseId;
  final int reps;
  final int sets;
  final int exerciseOrder;

  const WorkoutExercises({
    required this.workoutExercisesId,
    required this.workoutId,
    required this.exerciseId,
    required this.reps,
    required this.sets,
    required this.exerciseOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutExercisesId': workoutExercisesId,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'reps': reps,
      'sets': sets,
      'exerciseOrder': exerciseOrder,
    };
  }

  factory WorkoutExercises.fromMap(Map<String, dynamic> map) {
    return WorkoutExercises(
      workoutExercisesId: map['workoutExercisesId'],
      workoutId: map['workoutId'],
      exerciseId: map['exerciseId'],
      reps: map['reps'],
      sets: map['sets'],
      exerciseOrder: map['exerciseOrder'],
    );
  }
}