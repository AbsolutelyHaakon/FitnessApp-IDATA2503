class Workouts {
  final String workoutId;
  final String name;
  final String? description;
  final String? category;
  final int? duration;
  final int? intensity;
  final String? videoUrl;
  final bool isPrivate;
  final String userId;
  final bool isActive = false;

  const Workouts({
    required this.workoutId,
    required this.name,
    this.description,
    this.category,
    this.duration,
    this.intensity,
    this.videoUrl,
    required this.isPrivate,
    required this.userId,
  });

  // Convert a Workout object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'name': name,
      'description': description,
      'category': category,
      'duration': duration,
      'intensity': intensity,
      'videoUrl': videoUrl,
      'isPrivate': isPrivate ? 1 : 0,
      'userId': userId,
    };
  }

  // Extract a Workout object from a Map object
  factory Workouts.fromMap(Map<String, dynamic> map) {
    return Workouts(
      workoutId: map['workoutId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      duration: map['duration'],
      intensity: map['intensity'],
      videoUrl: map['videoUrl'],
      isPrivate: map['isPrivate'] == 1,
      userId: map['userId'],
    );
  }

  // Extract a Workout object from a Map object (for Sqflite)
  factory Workouts.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Workouts(
      workoutId: map['workoutId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      duration: map['duration'],
      intensity: map['intensity'],
      videoUrl: map['videoUrl'],
      isPrivate: map['isPrivate'] == 1,
      userId: map['userId'],
    );
  }
}