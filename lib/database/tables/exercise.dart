import 'dart:convert';

/// This class represents an exercise in the workout app.
/// It contains details about the exercise such as its name, description, category, etc.
class Exercises {
  final String exerciseId; // Unique identifier for the exercise
  String name; // Name of the exercise
  String? description; // Description of the exercise
  String? category; // Category of the exercise (e.g., cardio, strength)
  String? videoUrl; // URL to a video demonstrating the exercise
  String? imageURL; // URL to an image of the exercise
  bool isPrivate; // Whether the exercise is private or not
  String? userId; // ID of the user who created the exercise

  // Constructor for the Exercises class
  Exercises({
    required this.exerciseId,
    required this.name,
    this.description,
    this.category,
    this.videoUrl,
    this.imageURL,
    required this.isPrivate,
    this.userId,
  });

  // Converts an Exercises object to a map
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'imageURL': imageURL,
      'isPrivate': isPrivate ? 1 : 0, // Store as int
      'userId': userId,
    };
  }

  // Creates an Exercises object from a map
  factory Exercises.fromMap(Map<String, dynamic> map) {
    return Exercises(
      exerciseId: map['exerciseId'] as String,
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      imageURL: map['imageURL'],
      isPrivate: map['isPrivate'] == 1,
      userId: map['userId'],
    );
  }

  // Creates an Exercises object from a map specifically for SQLite
  factory Exercises.fromSqfl(Map<String, dynamic> map) {
    return Exercises(
      exerciseId: map['exerciseId'] as String,
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      imageURL: map['imageURL'],
      isPrivate: map['isPrivate'] == 1,
      userId: map['userId'],
    );
  }

  // Converts an Exercises object to JSON
  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'name': name,
    'description': description,
    'category': category,
    'videoUrl': videoUrl,
    'imageURL': imageURL,
    'isPrivate': isPrivate,
    'userId': userId,
  };

  // Returns the name of the exercise as a string
  @override
  String toString() {
    return name;
  }

  // Checks if two Exercises objects are equal based on their name
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Exercises &&
              runtimeType == other.runtimeType &&
              name == other.name;

  // Returns the hash code for the exercise based on its name
  @override
  int get hashCode => name.hashCode;
}