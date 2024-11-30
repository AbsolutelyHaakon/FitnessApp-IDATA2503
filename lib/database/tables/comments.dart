/// This class represents a comment on a post in the social feed.
/// It contains information about the comment's ID, the post it belongs to,
/// the user who made the comment, the content of the comment, and the date it was made.
class Comments {
  final String commentId; // Unique identifier for the comment
  final String postId; // ID of the post this comment belongs to
  final String userId; // ID of the user who made the comment

  final String content; // The actual content of the comment
  final DateTime date; // The date the comment was made

  // Constructor for the Comments class
  const Comments({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.date,
  });

  // Converts a Comments object to a map
  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'content': content,
      'date': date,
    };
  }

  // Creates a Comments object from a map
  factory Comments.fromMap(Map<String, dynamic> map) {
    return Comments(
      commentId: map['commentId'],
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}