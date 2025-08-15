class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'community', 'admin', 'personal'
  final String? imageUrl;
  final int likes;
  final int comments;
  final bool fromAdmin;
  final bool read;
  final DateTime time;
  final bool community;
  final bool isPersonal;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.fromAdmin = false,
    this.read = false,
    required this.time,
    required this.community,
    this.isPersonal = false,
  });
}
