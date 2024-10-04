class Workout {
  final int? id;
  final String name;
  final String? description;
  final String? category;

  const Workout({
    this.id,
    required this.name,
    this.description,
    this.category,
  });

  // Convert a Workout object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  // Extract a Workout object from a Map object
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
    );
  }

  // Extract a Workout object from a Map object (for Sqflite)
  factory Workout.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Workout(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
    );
  }
}