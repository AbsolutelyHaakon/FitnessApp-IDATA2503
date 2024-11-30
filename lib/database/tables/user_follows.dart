import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represents the relationship between users and their followers.
/// It contains information about the user who is following and the user being followed.
class UserFollows {
  final String userFollowsId; // Unique identifier for the follow relationship
  final String userId; // ID of the user who is following
  final String followsId; // ID of the user being followed

  // Constructor for the UserFollows class
  const UserFollows({
    required this.userFollowsId,
    required this.userId,
    required this.followsId,
  });

  // Converts a UserFollows object to a map
  Map<String, dynamic> toMap() {
    return {
      'userFollowsId': userFollowsId, // Add userFollowsId to map
      'userId': userId, // Add userId to map
      'followsId': followsId, // Add followsId to map
    };
  }

  // Creates a UserFollows object from a map
  factory UserFollows.fromMap(Map<String, dynamic> map) {
    return UserFollows(
      userFollowsId: map['userFollowsId'], // Get userFollowsId from map
      userId: map['userId'], // Get userId from map
      followsId: map['followsId'], // Get followsId from map
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Firebase Functions ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  // Gets the number of followers for a user from Firebase
  Future<int> fireBaseGetFollowerCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('followsId', isEqualTo: uid)
        .get();
    return querySnapshot.size; // Return the number of followers
  }

  // Gets the number of users a user is following from Firebase
  Future<int> fireBaseGetFollowingCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: uid)
        .get();
    return querySnapshot.size; // Return the number of users the user is following
  }
}