class Exercises {
  final int? exerciseId;
  final String name;
  final String? description;
  final String? category;
  final String? videoUrl;
  final int? lastWeight;

  const Exercises({
    this.exerciseId,
    required this.name,
    this.description,
    this.category,
    this.videoUrl,
    this.lastWeight,
  });

  // Convert an Exercise object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'lastWeight': lastWeight,
    };
  }

  // Extract an Exercise object from a Map object
  factory Exercises.fromMap(Map<String, dynamic> map) {
    return Exercises(
      exerciseId: map['exerciseId']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      lastWeight: map['lastWeight']?.toInt(),
    );
  }

  // Extract an Exercise object from a Map object (for Sqflite)
  factory Exercises.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Exercises(
      exerciseId: map['exerciseID']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      lastWeight: map['lastWeight']?.toInt(),
    );
  }
}