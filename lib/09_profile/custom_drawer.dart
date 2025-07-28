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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          // Enhanced User Header
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue : Colors.blueAccent,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
<<<<<<< HEAD
                      : const AssetImage('assets/default_profile.jpg') as ImageProvider,
=======
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
                  backgroundColor: Colors.white30,
                  child: profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
<<<<<<< HEAD
                  child: Column( 
=======
                  child: Column(
>>>>>>> 5df6cc5861a138b5fb059e14e406343467db6cc2
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Premium Member',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.store,
                  title: 'Market',
                  route: '/market',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.wb_sunny,
                  title: 'Weather',
                  route: '/weather',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.forum,
                  title: 'Community Forum',
                  route: '/forum',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'My Profile',
                  route: '/profile',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Hire Services',
                  route: '/hire',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.agriculture,
                  title: 'My Farm',
                  route: '/myfarm',
                ),
                const Divider(height: 20),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  route: '/help',
                ),
              ],
            ),
          ),

          // Footer with Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    // Call your auth sign out method here
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'App Version 1.0.0',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? route,
        Color? color,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? theme.textTheme.bodyLarge?.color,
          fontWeight: route != null ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      onTap: onTap ??
              () {
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 24,
    );
  }
}