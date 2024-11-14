import 'package:cloud_firestore/cloud_firestore.dart';

class UserWorkouts {
  final String userWorkoutId;
  final String userId;
  final String workoutId;
  final DateTime date;

  const UserWorkouts({
    required this.userWorkoutId,
    required this.userId,
    required this.workoutId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userWorkoutId': userWorkoutId,
      'userId': userId,
      'workoutId': workoutId,
      'date': date,
    };
  }

  factory UserWorkouts.fromMap(Map<String, dynamic> map) {
    return UserWorkouts(
      userWorkoutId: map['userWorkoutId'],
      userId: map['userId'],
      workoutId: map['workoutId'],
      date: map['date'] is Timestamp ? (map['date'] as Timestamp).toDate() : DateTime.parse(map['date']),
    );
  }
}