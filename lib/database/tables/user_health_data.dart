import 'package:cloud_firestore/cloud_firestore.dart';

class UserHealthData {
  final String userHealthDataId;
  final String userId;
  final DateTime date;
  final int weight;
  final int? height;
  final int? caloriesIntake;
  final int? caloriesBurned;
  final int? waterIntake;

  const UserHealthData({
    required this.userHealthDataId,
    required this.userId,
    required this.date,
    this.weight = 0,
    this.height = 0,
    this.caloriesIntake = 0,
    this.caloriesBurned = 0,
    this.waterIntake = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userHealthDataId': userHealthDataId,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'caloriesIntake': caloriesIntake,
      'caloriesBurned': caloriesBurned,
      'waterIntake': waterIntake,
    };
  }

  factory UserHealthData.fromMap(Map<String, dynamic> map) {
  return UserHealthData(
    userHealthDataId: map['userHealthDataId'],
    userId: map['userId'],
    date: map['date'] is Timestamp
        ? (map['date'] as Timestamp).toDate()
        : DateTime.parse(map['date']),
    weight: map['weight'] ?? 0,
    height: map['height'] ?? 0,
    caloriesIntake: map['caloriesIntake'] ?? 0,
    caloriesBurned: map['caloriesBurned'] ?? 0,
    waterIntake: map['waterIntake'] ?? 0,
  );
}
}
