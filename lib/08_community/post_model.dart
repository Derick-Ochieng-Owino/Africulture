import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      authorId: doc['authorId'],
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }
}