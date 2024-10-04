enum WorkoutCategory {
  general,
  strength,
  cardio,
  flexibility,
  balance,
}

// TODO: Add time, cal and sets to the workout do be displayed

class Workout {
  final int? id;
  final String name;
  final String? description;
  final WorkoutCategory? category;

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
      'category': category?.index, // Store enum as int
    };
  }

  // Extract a Workout object from a Map object
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'] != null ? WorkoutCategory.values[map['category']] : null,
    );
  }

  // Extract a Workout object from a Map object (for Sqflite)
  factory Workout.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Workout(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'] != null ? WorkoutCategory.values[map['category']] : null,
    );
  }
}