import 'package:cloud_firestore/cloud_firestore.dart';

class UserFollows {
  final String userFollowsId;
  final String userId;
  final String followsId;

  const UserFollows(
      {required this.userFollowsId,
      required this.userId,
      required this.followsId});

  Map<String, dynamic> toMap() {
    return {
      'userFollowsId': userFollowsId,
      'userId': userId,
      'followsId': followsId,
    };
  }

  factory UserFollows.fromMap(Map<String, dynamic> map) {
    return UserFollows(
        userFollowsId: map['userFollowsId'],
        userId: map['userId'],
        followsId: map['followsId']);
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Firebase Functions ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<int> fireBaseGetFollowerCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('followsId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

  Future<int> fireBaseGetFollowingCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

}
