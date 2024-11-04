class UserHealthData {
  final String userHealthDataId;
  final String userId;
  final DateTime date;
  final int weight;
  final int height;

  const UserHealthData({
    required this.userHealthDataId,
    required this.userId,
    required this.date,
    this.weight = 0,
    this.height = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userHealthDataId': userHealthDataId,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
    };
  }

  factory UserHealthData.fromMap(Map<String, dynamic> map) {
    return UserHealthData(
      userHealthDataId: map['userHealthDataId'],
      userId: map['userId'],
      date: DateTime.parse(map['date']),
      weight: map['weight'],
      height: map['height'],
    );
  }
}