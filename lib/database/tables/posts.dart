class Posts {
  final String postId;
  final String userId;
  final String? title;
  final String content;
  final String? image_url;
  final DateTime date;

  const Posts({
    required this.postId,
    required this.userId,
    this.title,
    required this.content,
    this.image_url,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'title': title,
      'content': content,
      'image_url': image_url,
      'date': date,
    };
  }

  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      postId: map['postId'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      image_url: map['image_url'],
      date: DateTime.parse(map['date']),
    );
  }
}