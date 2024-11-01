class Comments {
  final String commentId;
  final String postId;
  final String userId;

  final String content;
  final DateTime date;

  const Comments({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.date,
  });

  Map<String, dynamic>toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'content': content,
      'date': date,
    };
  }

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