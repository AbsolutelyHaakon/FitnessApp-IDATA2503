class WorkoutDate {
  final int userId;
  final int workoutId;
  final DateTime date;

  const WorkoutDate({
    required this.userId,
    required this.workoutId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workoutId': workoutId,
      'date': date.toIso8601String(),
    };
  }

  factory WorkoutDate.fromMap(Map<String, dynamic> map) {
    return WorkoutDate(
      userId: map['userId'],
      workoutId: map['workoutId'],
      date: DateTime.parse(map['date']),
    );
  }
}