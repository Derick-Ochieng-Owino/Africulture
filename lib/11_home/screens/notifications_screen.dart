import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'New weather alert in your region!',
      'Market prices updated for maize and beans.',
      'New farming tips available.',
      'You have a new message in the forum.',
      'Don’t forget to water your crops today!',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.green),
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}
