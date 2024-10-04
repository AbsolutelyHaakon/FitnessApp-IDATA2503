class Exercise {
  final int? id;
  final String name;
  final String? description;
  // TODO: Change this into it´s own class "category"
  final String? category;
  final String? videoUrl;
  final int? lastWeight;

  const Exercise({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.videoUrl,
    this.lastWeight,
  });

  // Convert an Exercise object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'lastWeight': lastWeight,
    };
  }

  // Extract an Exercise object from a Map object
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      lastWeight: map['lastWeight']?.toInt(),
    );
  }

  // Extract an Exercise object from a Map object (for Sqflite)
  factory Exercise.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      lastWeight: map['lastWeight']?.toInt(),
    );
  }
}