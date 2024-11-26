import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String postId;
  final String userId;
  final String? content;
  final String? imageURL;
  final DateTime date;
  final String? workoutId;
  final String? location;
  final Map<String, String>? visibleStats;

  const Posts({
    required this.postId,
    required this.userId,
    this.content,
    this.imageURL,
    required this.date,
    this.workoutId,
    this.location,
    this.visibleStats,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'imageURL': imageURL,
      'date': date.toIso8601String(),
      'workoutId': workoutId,
      'location': location,
      'visibleStats': visibleStats,
    };
  }

  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      imageURL: map['imageURL'],
      date: map['date'] is Timestamp ? (map['date'] as Timestamp).toDate() : DateTime.parse(map['date']),
      workoutId: map['workoutId'],
      location: map['location'],
      visibleStats: (map['visibleStats'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
    );
  }
}