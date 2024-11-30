import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represents the health data of a user.
/// It contains information such as the user's weight, height, calorie intake, calories burned, and water intake.
class UserHealthData {
  final String userHealthDataId; // Unique identifier for the health data entry
  final String userId; // ID of the user this health data belongs to
  final DateTime date; // Date of the health data entry
  final int weight; // Weight of the user
  final int? height; // Height of the user
  final int? caloriesIntake; // Calories intake of the user
  final int? caloriesBurned; // Calories burned by the user
  final int? waterIntake; // Water intake of the user

  // Constructor for the UserHealthData class
  const UserHealthData({
    required this.userHealthDataId, // Initialize userHealthDataId
    required this.userId, // Initialize userId
    required this.date, // Initialize date
    this.weight = 0, // Initialize weight with default value 0
    this.height = 0, // Initialize height with default value 0
    this.caloriesIntake = 0, // Initialize caloriesIntake with default value 0
    this.caloriesBurned = 0, // Initialize caloriesBurned with default value 0
    this.waterIntake = 0, // Initialize waterIntake with default value 0
  });

  // Convert a UserHealthData object to a map
  Map<String, dynamic> toMap() {
    return {
      'userHealthDataId': userHealthDataId, // Add userHealthDataId to map
      'userId': userId, // Add userId to map
      'date': date.toIso8601String(), // Add date to map in ISO 8601 format
      'weight': weight, // Add weight to map
      'height': height, // Add height to map
      'caloriesIntake': caloriesIntake, // Add caloriesIntake to map
      'caloriesBurned': caloriesBurned, // Add caloriesBurned to map
      'waterIntake': waterIntake, // Add waterIntake to map
    };
  }

  // Create a UserHealthData object from a map
  factory UserHealthData.fromMap(Map<String, dynamic> map) {
    return UserHealthData(
      userHealthDataId: map['userHealthDataId'], // Get userHealthDataId from map
      userId: map['userId'], // Get userId from map
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : DateTime.parse(map['date']), // Parse date string to DateTime
      weight: map['weight'] ?? 0, // Get weight from map or default to 0
      height: map['height'] ?? 0, // Get height from map or default to 0
      caloriesIntake: map['caloriesIntake'] ?? 0, // Get caloriesIntake from map or default to 0
      caloriesBurned: map['caloriesBurned'] ?? 0, // Get caloriesBurned from map or default to 0
      waterIntake: map['waterIntake'] ?? 0, // Get waterIntake from map or default to 0
    );
  }
}