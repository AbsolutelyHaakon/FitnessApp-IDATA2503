import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represents the workouts of a user.
/// It contains information about the workout such as the user ID, workout ID, date, duration, statistics, and whether the workout is active.
class UserWorkouts {
  final String userWorkoutId; // Unique identifier for the user workout
  final String userId; // ID of the user who performed the workout
  final String workoutId; // ID of the workout
  final DateTime date; // Date of the workout
  final double? duration; // Duration of the workout in hours
  final String? statistics; // Additional statistics about the workout
  final bool isActive; // Whether the workout is currently active

  // Constructor for the UserWorkouts class
  const UserWorkouts({
    required this.userWorkoutId, // Initialize userWorkoutId
    required this.userId, // Initialize userId
    required this.workoutId, // Initialize workoutId
    required this.date, // Initialize date
    this.duration, // Initialize duration (optional)
    this.statistics, // Initialize statistics (optional)
    required this.isActive, // Initialize isActive
  });

  // Convert a UserWorkouts object to a map
  Map<String, dynamic> toMap() {
    return {
      'userWorkoutId': userWorkoutId.toString(), // Add userWorkoutId to map
      'userId': userId, // Add userId to map
      'workoutId': workoutId, // Add workoutId to map
      'date': date.toIso8601String(), // Add date to map in ISO 8601 format
      'duration': duration, // Add duration to map
      'statistics': statistics != null ? jsonEncode(statistics) : null, // Add statistics to map (if not null)
      'isActive': isActive ? 1 : 0, // Add isActive to map (convert bool to int)
    };
  }

  // Create a UserWorkouts object from a map
  factory UserWorkouts.fromMap(Map<String, dynamic> map) {
    return UserWorkouts(
      userWorkoutId: map['userWorkoutId'].toString(), // Get userWorkoutId from map
      userId: map['userId'], // Get userId from map
      workoutId: map['workoutId'], // Get workoutId from map
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : DateTime.parse(map['date']), // Parse date string to DateTime
      duration: map['duration'] != null ? (map['duration'] as num).toDouble() : null, // Get duration from map (convert to double if not null)
      statistics: map['statistics'] is String ? map['statistics'] : jsonEncode(map['statistics']), // Get statistics from map (convert to JSON string if not null)
      isActive: map['isActive'] == 1, // Get isActive from map (convert int to bool)
    );
  }
}