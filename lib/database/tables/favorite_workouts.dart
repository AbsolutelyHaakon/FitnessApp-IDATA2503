/// This class represents a user's favorite workout.
/// It contains information about the favorite workout's ID, the user who favorited it, and the workout ID.
class FavoriteWorkouts {
  final String favoriteWorkoutId; // Unique identifier for the favorite workout
  final String userId; // ID of the user who favorited the workout
  final String workoutId; // ID of the workout that was favorited

  // Constructor for the FavoriteWorkouts class
  const FavoriteWorkouts({
    required this.favoriteWorkoutId,
    required this.userId,
    required this.workoutId,
  });

  // Converts a FavoriteWorkouts object to a map
  Map<String, dynamic> toMap() {
    return {
      'favoriteWorkoutId': favoriteWorkoutId.toString(),
      'userId': userId,
      'workoutId': workoutId,
    };
  }

  // Creates a FavoriteWorkouts object from a map
  factory FavoriteWorkouts.fromMap(Map<String, dynamic> map) {
    return FavoriteWorkouts(
      favoriteWorkoutId: map['favoriteWorkoutId'].toString(),
      userId: map['userId'],
      workoutId: map['workoutId'],
    );
  }
}