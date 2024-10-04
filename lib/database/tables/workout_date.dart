class WorkoutDate {
  final int workoutId;
  final DateTime date;

  const WorkoutDate({
    required this.workoutId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'date': date.toIso8601String(),
    };
  }

  factory WorkoutDate.fromMap(Map<String, dynamic> map) {
    return WorkoutDate(
      workoutId: map['workoutId'],
      date: DateTime.parse(map['date']),
    );
  }
}