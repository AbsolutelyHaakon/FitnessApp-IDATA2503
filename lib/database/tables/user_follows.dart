class UserFollows {
  final int userId;
  final int followsId;

  const UserFollows({
    required this.userId,
    required this.followsId
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'followsId': followsId,
    };
  }

  factory UserFollows.fromMap(Map<String, dynamic> map) {
    return UserFollows(
      userId: map['userId'],
      followsId: map['followsId']);
  }
}