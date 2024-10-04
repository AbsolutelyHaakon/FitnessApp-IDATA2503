class UserWeightData {
  final int id;
  final int userId;
  final int weight;
  final String date;

  UserWeightData({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
  });

  // Convert a UserWeightData object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'date': date,
    };
  }

  // Extract a UserWeightData object from a Map object
  factory UserWeightData.fromMap(Map<String, dynamic> map) {
    return UserWeightData(
      id: map['id']?.toInt() ?? 0,
      userId: map['userId']?.toInt() ?? 0,
      weight: map['weight']?.toInt() ?? 0,
      date: map['date'] ?? '',
    );
  }
}