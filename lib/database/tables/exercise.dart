class Exercises {
  final String exerciseId;
  final String name;
  final String? description;
  final String? category;
  final String? videoUrl;
  final String? imageURL;
  final bool isPrivate;
  final String? userId;

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

  factory Exercises.fromMap(Map<String, dynamic> map) {
    return Exercises(
      exerciseId: map['exerciseId'] as String,
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      videoUrl: map['videoUrl'],
      imageURL: map['imageURL'],
      isPrivate: map['isPrivate'],
      userId: map['userId'],
    );
  }

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
}