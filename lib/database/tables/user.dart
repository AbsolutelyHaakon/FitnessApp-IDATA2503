class LocalUser {
  final String userId;
  final String name;
  final String email;
  final double? weight;
  final double? targetWeight;
  final double? height;
  final String? imageURL;

  const LocalUser({
    required this.userId,
    required this.name,
    required this.email,
    this.weight,
    this.targetWeight,
    this.height,
    this.imageURL
  });

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'weight': weight,
      'targetWeight': targetWeight,
      'height': height,
      'imageURL': imageURL,
    };
  }

  // Extract a User object from a Map object
  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight'],
      targetWeight: map['targetWeight'],
      height: map['height'],
      imageURL: map['imageURL'],
    );
  }

  // Extract a User object from a Map object (for Sqflite)
  factory LocalUser.fromSqfliteDatabase(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight']?.toDouble(),
      targetWeight: map['targetWeight']?.toDouble(),
      height: map['height']?.toDouble(),
      imageURL: map['imageURL'],
    );
  }
}