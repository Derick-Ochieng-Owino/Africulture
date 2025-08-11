import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profileImageUrl;
  final String location;

  const AdminDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileImageUrl,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Admin Profile',
                  color: Colors.blue,
                  onTap: () => {
                    Navigator.pushReplacementNamed(context, '/admin_profile')
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Overview Dashboard',
                  color: primaryColor,
                  onTap: () => Navigator.pushReplacementNamed(context, '/adminDashboard'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'User Management',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/users');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.post_add,
                  title: 'Posts / Content',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/content_and_posts');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.attach_money,
                  title: 'Revenue & Sales',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/users');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Analytics',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/analytics');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Alerts & Issues',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/admin_Notifications');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'Activity Logs',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/users');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Pending Approvals',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/product_approval');
                  },
                ),
                const Divider(height: 20, indent: 20, endIndent: 20),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Admin Settings',
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/admin_settings');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Support Center',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/users');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white30,
            child: ClipOval(
              child: Image.network(
                profileImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text('Admin', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                  ],
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
        required Color color,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
