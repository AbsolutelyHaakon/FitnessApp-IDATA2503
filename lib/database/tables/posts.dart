import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represents a post in the social feed.
/// It contains information about the post's ID, the user who made the post,
/// the content of the post, the image URL, the date it was made, the workout ID,
/// the location, and any visible statistics.
class Posts {
  final String postId; // Unique identifier for the post
  final String userId; // ID of the user who made the post
  final String? content; // The actual content of the post
  final String? imageURL; // URL to an image associated with the post
  final DateTime date; // The date the post was made
  final String? userWorkoutsId; // ID of the workout associated with the post
  final String? location; // Location where the post was made
  final Map<String, String>? visibleStats; // Stats visible to other users

  // Constructor for the Posts class
  const Posts({
    required this.postId,
    required this.userId,
    this.content,
    this.imageURL,
    required this.date,
    this.userWorkoutsId,
    this.location,
    this.visibleStats,
  });

  // Converts a Posts object to a map
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'imageURL': imageURL,
      'date': date.toIso8601String(),
      'userWorkoutsId': userWorkoutsId,
      'location': location,
      'visibleStats': visibleStats,
    };
  }

  // Creates a Posts object from a map
  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      imageURL: map['imageURL'],
      date: map['date'] is Timestamp ? (map['date'] as Timestamp).toDate() : DateTime.parse(map['date']),
      userWorkoutsId: map['userWorkoutsId'],
      location: map['location'],
      visibleStats: (map['visibleStats'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
    );
  }
}