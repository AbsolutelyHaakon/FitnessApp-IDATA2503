class LocalUser {
  final String id;
  final String name;
  final String email;
  final double? weight;
  final double? height;

  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    this.weight,
    this.height,
  });

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
    };
  }

  // Extract a User object from a Map object
  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight'],
      height: map['height'],
    );
  }

  // Extract a User object from a Map object (for Sqflite)
  factory LocalUser.fromSqfliteDatabase(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
    );
  }
}