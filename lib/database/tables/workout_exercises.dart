/// This class represents the exercises that are part of a workout.
/// Each exercise has a unique ID, belongs to a specific workout,
/// and has details like the number of reps, sets, and the order of the exercise.
class WorkoutExercises {
  // Unique identifier for the workout exercise
  final String workoutExercisesId;
  // ID of the workout this exercise belongs to
  final String workoutId;
  // ID of the exercise
  final String exerciseId;
  // Number of repetitions for the exercise
  final int reps;
  // Number of sets for the exercise
  final int sets;
  // Order of the exercise in the workout
  final int exerciseOrder;

  // Constructor for the WorkoutExercises class
  const WorkoutExercises({
    required this.workoutExercisesId, // Initialize workoutExercisesId
    required this.workoutId, // Initialize workoutId
    required this.exerciseId, // Initialize exerciseId
    required this.reps, // Initialize reps
    required this.sets, // Initialize sets
    required this.exerciseOrder, // Initialize exerciseOrder
  });

  // Convert a WorkoutExercises object to a map
  Map<String, dynamic> toMap() {
    return {
      'workoutExercisesId': workoutExercisesId, // Add workoutExercisesId to map
      'workoutId': workoutId, // Add workoutId to map
      'exerciseId': exerciseId, // Add exerciseId to map
      'reps': reps, // Add reps to map
      'sets': sets, // Add sets to map
      'exerciseOrder': exerciseOrder, // Add exerciseOrder to map
    };
  }

  // Create a WorkoutExercises object from a map
  factory WorkoutExercises.fromMap(Map<String, dynamic> map) {
    return WorkoutExercises(
      workoutExercisesId: map['workoutExercisesId'], // Get workoutExercisesId from map
      workoutId: map['workoutId'], // Get workoutId from map
      exerciseId: map['exerciseId'], // Get exerciseId from map
      reps: map['reps'], // Get reps from map
      sets: map['sets'], // Get sets from map
      exerciseOrder: map['exerciseOrder'], // Get exerciseOrder from map
    );
  }
}