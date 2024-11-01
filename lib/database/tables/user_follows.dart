class UserFollows {
  final String userId;
  final String followsId;

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