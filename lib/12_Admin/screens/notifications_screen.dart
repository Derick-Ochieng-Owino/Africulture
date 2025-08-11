import 'package:africulture/12_Admin/widgets/common/app_bar.dart';
import 'package:africulture/12_Admin/widgets/common/app_drawer.dart';
import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(userName: 'userName', userEmail: 'userEmail', profileImageUrl: 'profileImageUrl', location: 'location'),
      appBar: AdminAppBar(title: 'Notifications'),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text('Notification ${index + 1}'),
                  subtitle: const Text('This is a sample notification message'),
                  trailing: const Text('2h ago'),
                  onTap: () {},
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}