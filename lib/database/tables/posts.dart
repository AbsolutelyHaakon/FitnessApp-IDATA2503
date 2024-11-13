class Posts {
  final String postId;
  final String userId;
  final String? content;
  final String? imageURL;
  final DateTime date;
  final String? workoutId;
  final String? location;

  const Posts({
    required this.postId,
    required this.userId,
    this.content,
    this.imageURL,
    required this.date,
    this.workoutId,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'imageURL': imageURL,
      'date': date,
      'workoutId': workoutId,
      'location': location,
    };
  }

  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      imageURL: map['imageURL'],
      date: DateTime.parse(map['date']),
      workoutId: map['workoutId'],
      location: map['location'],
    );
  }
}