class Posts {
  final int postId;
  final int userId;
  final String postContent;
  final String postImage;
  final String postDate;

  const Posts({
    required this.postId,
    required this.userId,
    required this.postContent,
    required this.postImage,
    required this.postDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'postContent': postContent,
      'postImage': postImage,
      'postDate': postDate,
    };
  }

  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      postId: map['postId'],
      userId: map['userId'],
      postContent: map['postContent'],
      postImage: map['postImage'],
      postDate: map['postDate'],
    );
  }
}