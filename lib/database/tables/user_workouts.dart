class UserWorkouts {
  final String userId;
  final String workoutId;
  final DateTime date;

  const UserWorkouts({
    required this.userId,
    required this.workoutId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workoutId': workoutId,
      'date': date,
    };
  }

  factory UserWorkouts.fromMap(Map<String, dynamic> map) {
    return UserWorkouts(
      userId: map['userId'],
      workoutId: map['workoutId'],
      date: DateTime.parse(map['date']),
    );
  }
}