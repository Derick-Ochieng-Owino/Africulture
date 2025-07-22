import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profileImageUrl;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
          ),

          // Market
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Market'),
            onTap: () {
              Navigator.pushNamed(context, '/market');
            },
          ),
          const Divider(),
          // Weather
          ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: const Text('Weather'),
            onTap: () {
              Navigator.pushNamed(context, '/weather');
            },
          ),
          const Divider(),
          // Forum
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Forum'),
            onTap: () {
              Navigator.pushNamed(context, '/forum');
            },
          ),
          const Divider(),
          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bus_alert),
            title: const Text('Hire'),
            onTap: () {
              Navigator.pushNamed(context, '/market');
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Call your auth sign out method here
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
