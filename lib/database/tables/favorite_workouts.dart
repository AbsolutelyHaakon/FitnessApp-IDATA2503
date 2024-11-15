
class FavoriteWorkouts {
  final String favoriteWorkoutId;
  final String userId;
  final String workoutId;

  const FavoriteWorkouts({
    required this.favoriteWorkoutId,
    required this.userId,
    required this.workoutId,
  });

  Map<String, dynamic> toMap() {
    return {
      'favoriteWorkoutId': favoriteWorkoutId,
      'userId': userId,
      'workoutId': workoutId,
    };
  }

  factory FavoriteWorkouts.fromMap(Map<String, dynamic> map) {
    return FavoriteWorkouts(
      favoriteWorkoutId: map['favoriteWorkoutId'],
      userId: map['userId'],
      workoutId: map['workoutId'],
    );
  }
}