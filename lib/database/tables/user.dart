class LocalUser {
  final String userId;
  final String name;
  final String email;
  final int? weight;
  final int? weightTarget;
  final int? weightInitial;
  final double? height;
  final String? imageURL;
  final String? bannerURL;
  final int? waterTarget;
  final int? caloriesIntakeTarget;
  final int? caloriesBurnedTarget;

  const LocalUser({
    required this.userId,
    required this.name,
    required this.email,
    this.weight,
    this.weightTarget,
    this.weightInitial,
    this.height,
    this.imageURL,
    this.bannerURL,
    this.waterTarget,
    this.caloriesIntakeTarget,
    this.caloriesBurnedTarget,
  });

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'weight': weight,
      'targetWeight': weightTarget,
      'weightInitial': weightInitial,
      'height': height,
      'imageURL': imageURL,
      'bannerURL': bannerURL,
      'waterTarget': waterTarget,
      'caloriesIntakeTarget': caloriesIntakeTarget,
      'caloriesBurnedTarget': caloriesBurnedTarget,
    };
  }

  // Extract a User object from a Map object
  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight'],
      weightTarget: map['weightTarget'],
      weightInitial: map['weightInitial'],
      height: (map['height'] as num?)?.toDouble(),
      imageURL: map['imageURL'],
      bannerURL: map['bannerURL'],
      waterTarget: map['waterTarget'],
      caloriesIntakeTarget: map['caloriesIntakeTarget'],
      caloriesBurnedTarget: map['caloriesBurnedTarget'],
    );
  }

  // Extract a User object from a Map object (for Sqflite)
  factory LocalUser.fromSqfliteDatabase(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: map['weight'],
      weightTarget: map['weightTarget'],
      weightInitial: map['weightInitial'],
      height: map['height']?.toDouble(),
      imageURL: map['imageURL'],
      bannerURL: map['bannerURL'],
      waterTarget: map['waterTarget'],
      caloriesIntakeTarget: map['caloriesIntakeTarget'],
      caloriesBurnedTarget: map['caloriesBurnedTarget'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}