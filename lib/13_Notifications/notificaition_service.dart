import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_model.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

class NotificationService {
  Stream<List<NotificationItem>> getNotificationsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .snapshots();
    final productsStream = FirebaseFirestore.instance
        .collection('products')
        .snapshots();
    final adminStream = FirebaseFirestore.instance.collection(
        'admin_notifications').snapshots();

    return rxdart.Rx.combineLatest3(
      postsStream,
      productsStream,
      adminStream,
          (QuerySnapshot postsSnap, QuerySnapshot productsSnap,
          QuerySnapshot adminSnap) {
        List<NotificationItem> notifications = [];

        // Posts
        for (var doc in postsSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          notifications.add(NotificationItem(
            id: doc.id,
            title: data['title'] ?? '',
            body: data['content'] ?? '',
            type: 'community',
            imageUrl: data['imageUrl'],
            likes: (data['likes'] as List?)?.length ?? 0,
            comments: data['commentsCount'] ?? 0,
            time: (data['timestamp'] as Timestamp).toDate(),
            community: true,
          ));
        }

        // Products
        for (var doc in productsSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          notifications.add(NotificationItem(
            id: doc.id,
            title: data['name'] ?? '',
            body: data['description'] ?? '',
            type: 'product',
            imageUrl: data['imageUrl'],
            time: (data['createdAt'] as Timestamp).toDate(),
            community: false,
          ));
        }

        // Admin
        for (var doc in adminSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          notifications.add(NotificationItem(
            id: doc.id,
            title: data['title'] ?? '',
            body: data['body'] ?? '',
            type: 'admin',
            fromAdmin: true,
            time: (data['createdAt'] as Timestamp).toDate(),
            community: false,
          ));
        }

        // Sort by newest first
        notifications.sort((a, b) => b.time.compareTo(a.time));

        return notifications;
      },
    );
  }
}