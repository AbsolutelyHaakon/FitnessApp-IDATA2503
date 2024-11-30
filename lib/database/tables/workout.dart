class Workouts {
  // Unique identifier for the workout
  final String workoutId;
  // Name of the workout
  final String name;
  // Description of the workout (optional)
  final String? description;
  // Category of the workout (optional)
  final String? category;
  // Duration of the workout in minutes (optional)
  final int? duration;
  // Calories burned during the workout (optional)
  final int? calories;
  // Number of sets in the workout (optional)
  final int? sets;
  // Intensity level of the workout (optional)
  final int? intensity;
  // URL to the workout video (optional)
  final String? imageURL;
  // Whether the workout is private
  final bool isPrivate;
  // ID of the user who created the workout
  final String userId;
  // Whether the workout is currently active
  final bool isActive = false;
  // Whether the workout is deleted
  final bool isDeleted;

  // Constructor for the Workouts class
  const Workouts({
    required this.workoutId, // Initialize workoutId
    required this.name, // Initialize name
    this.description, // Initialize description (optional)
    this.category, // Initialize category (optional)
    this.duration, // Initialize duration (optional)
    this.calories, // Initialize calories (optional)
    this.sets, // Initialize sets (optional)
    this.intensity, // Initialize intensity (optional)
    this.imageURL, // Initialize videoUrl (optional)
    required this.isPrivate, // Initialize isPrivate
    required this.userId, // Initialize userId
    required this.isDeleted, // Initialize isDeleted
  });

  // Convert a Workout object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId, // Add workoutId to map
      'name': name, // Add name to map
      'description': description, // Add description to map
      'category': category, // Add category to map
      'duration': duration, // Add duration to map
      'calories': calories, // Add calories to map
      'sets': sets, // Add sets to map
      'intensity': intensity, // Add intensity to map
      'imageURL': imageURL, // Add imageURL to map
      'isPrivate': isPrivate ? 1 : 0, // Add isPrivate to map (convert bool to int)
      'userId': userId, // Add userId to map
      'isDeleted': isDeleted ? 1 : 0, // Add isDeleted to map (convert bool to int)
    };
  }

  // Extract a Workout object from a Map object
  factory Workouts.fromMap(Map<String, dynamic> map) {
    return Workouts(
      workoutId: map['workoutId'], // Get workoutId from map
      name: map['name'], // Get name from map
      description: map['description'], // Get description from map
      category: map['category'], // Get category from map
      duration: map['duration'], // Get duration from map
      calories: map['calories'], // Get calories from map
      sets: map['sets'], // Get sets from map
      intensity: map['intensity'], // Get intensity from map
      imageURL: map['imageURL'], // Get videoUrl from map
      isPrivate: map['isPrivate'] == 1, // Get isPrivate from map (convert int to bool)
      userId: map['userId'], // Get userId from map
      isDeleted: map['isDeleted'] == 1, // Get isDeleted from map (convert int to bool)
    );
  }

  // Extract a Workout object from a Map object (for Sqflite)
  factory Workouts.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Workouts(
      workoutId: map['workoutId'], // Get workoutId from map
      name: map['name'], // Get name from map
      description: map['description'], // Get description from map
      category: map['category'], // Get category from map
      duration: map['duration'], // Get duration from map
      calories: map['calories'], // Get calories from map
      sets: map['sets'], // Get sets from map
      intensity: map['intensity'], // Get intensity from map
      imageURL: map['imageURL'], // Get videoUrl from map
      isPrivate: map['isPrivate'] == 1, // Get isPrivate from map (convert int to bool)
      userId: map['userId'], // Get userId from map
      isDeleted: map['isDeleted'] == 1, // Get isDeleted from map (convert int to bool)
    );
  }
}