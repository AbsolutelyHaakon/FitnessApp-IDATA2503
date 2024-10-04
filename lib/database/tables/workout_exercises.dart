class WorkoutExercises {
  final int workoutId;
  final int exerciseId;

  const WorkoutExercises({
    required this.workoutId,
    required this.exerciseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'exerciseId': exerciseId,
    };
  }

  factory WorkoutExercises.fromMap(Map<String, dynamic> map) {
    return WorkoutExercises(
      workoutId: map['workoutId'],
      exerciseId: map['exerciseId'],
    );
  }
}