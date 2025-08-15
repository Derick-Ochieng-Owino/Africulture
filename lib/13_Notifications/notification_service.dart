import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_model.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class NotificationService {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<NotificationItem>> getNotificationsStream() {
    final userPostsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: uid)
        .snapshots();

    final adminStream = FirebaseFirestore.instance
        .collection('admin_notifications')
        .snapshots();

    final personalStream = FirebaseFirestore.instance
        .collection('personal_notifications')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots();

    return rxdart.Rx.combineLatest3(
      userPostsStream,
      adminStream,
      personalStream,
          (QuerySnapshot postsSnap, QuerySnapshot adminSnap, QuerySnapshot personalSnap) {
        List<NotificationItem> notifications = [];

        for (var doc in postsSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          int likeCount = (data['likes'] as List?)?.length ?? 0;
          int commentCount = data['commentsCount'] ?? 0;

          if (likeCount > 0) {
            notifications.add(NotificationItem(
              id: doc.id + "_like", // unique ID
              title: "Someone liked your post",
              body: "Your post \"${data['title']}\" has $likeCount likes.",
              type: 'likes',
              imageUrl: data['imageUrl'],
              time: (data['timestamp'] as Timestamp).toDate(),
              community: true,
            ));
          }

          if (commentCount > 0) {
            notifications.add(NotificationItem(
              id: doc.id + "_comment",
              title: "New comments on your post",
              body: "Your post \"${data['title']}\" has $commentCount comments.",
              type: 'comments',
              imageUrl: data['imageUrl'],
              time: (data['timestamp'] as Timestamp).toDate(),
              community: true,
            ));
          }
        }


        // Admin notifications
        for (var doc in adminSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          notifications.add(NotificationItem(
            id: doc.id,
            title: data['title'] ?? 'Admin Message',
            body: data['body'] ?? '',
            type: 'admin',
            fromAdmin: true,
            time: (data['createdAt'] as Timestamp).toDate(),
            community: false,
          ));
        }

        // Personal notifications
        for (var doc in personalSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          notifications.add(NotificationItem(
            id: doc.id,
            title: data['title'] ?? 'Welcome!',
            body: data['body'] ?? 'Thanks for joining Africulture.',
            type: 'personal',
            time: (data['time'] as Timestamp).toDate(),
            community: false,
            read: data['read'] ?? false,
          ));
        }

        notifications.sort((a, b) => b.time.compareTo(a.time));
        return notifications;
      },
    );
  }

  Future<void> markNotificationsAsRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('personal_notifications')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

}
