/// This class represents a user in the local database.
/// It contains details about the user such as their ID, name, email, weight, height, and various targets.
class LocalUser {
  final String userId; // Unique identifier for the user
  final String name; // Name of the user
  final String email; // Email of the user
  final int? weight; // Current weight of the user
  final int? weightTarget; // Target weight of the user
  final int? weightInitial; // Initial weight of the user
  final double? height; // Height of the user
  final String? imageURL; // URL to the user's profile image
  final String? bannerURL; // URL to the user's banner image
  final int? waterTarget; // Daily water intake target for the user
  final int? caloriesIntakeTarget; // Daily calorie intake target for the user
  final int? caloriesBurnedTarget; // Daily calorie burn target for the user

  // Constructor for the LocalUser class
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

  // Convert a LocalUser object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'weight': weight,
      'weightTarget': weightTarget,
      'weightInitial': weightInitial,
      'height': height,
      'imageURL': imageURL,
      'bannerURL': bannerURL,
      'waterTarget': waterTarget,
      'caloriesIntakeTarget': caloriesIntakeTarget,
      'caloriesBurnedTarget': caloriesBurnedTarget,
    };
  }

  // Extract a LocalUser object from a Map object
  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['userId'] ?? '', // Get userId from map or set to empty string if null
      name: map['name'] ?? '', // Get name from map or set to empty string if null
      email: map['email'] ?? '', // Get email from map or set to empty string if null
      weight: map['weight'], // Get weight from map
      weightTarget: map['weightTarget'], // Get weightTarget from map
      weightInitial: map['weightInitial'], // Get weightInitial from map
      height: (map['height'] as num?)?.toDouble(), // Convert height to double
      imageURL: map['imageURL'], // Get imageURL from map
      bannerURL: map['bannerURL'], // Get bannerURL from map
      waterTarget: map['waterTarget'], // Get waterTarget from map
      caloriesIntakeTarget: map['caloriesIntakeTarget'], // Get caloriesIntakeTarget from map
      caloriesBurnedTarget: map['caloriesBurnedTarget'], // Get caloriesBurnedTarget from map
    );
  }

  // Extract a LocalUser object from a Map object (for Sqflite)
  factory LocalUser.fromSqfliteDatabase(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['id'] ?? '', // Get id from map or set to empty string if null
      name: map['name'] ?? '', // Get name from map or set to empty string if null
      email: map['email'] ?? '', // Get email from map or set to empty string if null
      weight: map['weight'], // Get weight from map
      weightTarget: map['weightTarget'], // Get weightTarget from map
      weightInitial: map['weightInitial'], // Get weightInitial from map
      height: map['height']?.toDouble(), // Convert height to double
      imageURL: map['imageURL'], // Get imageURL from map
      bannerURL: map['bannerURL'], // Get bannerURL from map
      waterTarget: map['waterTarget'], // Get waterTarget from map
      caloriesIntakeTarget: map['caloriesIntakeTarget'], // Get caloriesIntakeTarget from map
      caloriesBurnedTarget: map['caloriesBurnedTarget'], // Get caloriesBurnedTarget from map
    );
  }

  // Convert a LocalUser object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Add userId to JSON
      'name': name, // Add name to JSON
      'email': email, // Add email to JSON
    };
  }
}