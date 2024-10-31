class LocalUser {
  final int? id;
  final String name;
  final String email;
  final String password;
  final int? weight;

  const LocalUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.weight,
  });

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'weight': weight,
    };
  }

  // Extract a User object from a Map object
  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      weight: map['weight']?.toInt(),
    );
  }

  // Extract a User object from a Map object (for Sqflite)
  factory LocalUser.fromSqfliteDatabase(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      weight: map['weight']?.toInt(),
    );
  }
}