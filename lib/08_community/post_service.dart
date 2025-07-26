import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deletePost(String postId, String currentUserId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists && doc.data()?['authorId'] == currentUserId) {
        await _firestore.collection('posts').doc(postId).delete();
      } else {
        throw Exception('Not authorized to delete this post');
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }
}