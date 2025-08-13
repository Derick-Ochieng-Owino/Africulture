import 'package:africulture/03_weather/weather_page.dart';
import 'package:africulture/05_hire/hire_page.dart';
import 'package:africulture/06_market/screens/agricommerce.dart';
import 'package:africulture/08_community/forum_page.dart';
import 'package:africulture/09_profile/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String profileImageUrl;
  final String location;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileImageUrl,
    required this.location,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? userType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserType();
  }

  Future<void> _fetchUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cacheDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.cache));

      if (cacheDoc.exists) {
        setState(() {
          userType = cacheDoc['userType'] ?? 'User';
          isLoading = false;
        });
      }

      final serverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (serverDoc.exists) {
        setState(() {
          userType = serverDoc['userType'] ?? 'User';
          isLoading = false;
        });
      } else {
        setState(() {
          userType = 'User';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        userType = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      elevation: 10,
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.9),
                  secondaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 40,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: _buildHeader(primaryColor),
          ),

          // Menu Items
          Expanded(
            child: isLoading
                ? Center(child: Lottie.asset('assets/animations/plant_grow.json', width: 120, height: 120))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 10),
                      _buildDrawerItem(
                        context,
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        color: primaryColor.withOpacity(0.8),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.subscriptions_outlined,
                        title: 'Subscriptions',
                        color: primaryColor.withOpacity(0.8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SubscriptionPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.store,
                        title: 'Marketplace',
                        color: Colors.green.withOpacity(0.7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AgriCommerceApp()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.cloud,
                        title: 'Weather',
                        color: Colors.blue.withOpacity(0.7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WeatherPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.forum,
                        title: 'Community',
                        color: Colors.purple.withOpacity(0.7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForumPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.agriculture,
                        title: 'My Farm',
                        color: Colors.brown.withOpacity(0.7),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.local_shipping,
                        title: 'Transport',
                        color: Colors.orange.withOpacity(0.7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransportHirePage()),
                          );
                        },
                      ),

                      // ✅ Show only if Admin
                      if (userType == 'Admin')
                        _buildDrawerItem(
                          context,
                          icon: Icons.admin_panel_settings,
                          title: 'Admin Dashboard',
                          color: Colors.red.withOpacity(0.8),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/adminDashboard',
                            );
                          },
                        ),

                      const Divider(height: 20, indent: 20, endIndent: 20),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        color: Colors.teal.withOpacity(0.7),
                      ),
                    ],
                  ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  color: Colors.red.withOpacity(0.8),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
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

  Widget _buildHeader(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white30,
                backgroundImage: NetworkImage(widget.profileImageUrl),
                onBackgroundImageError: (_, __) =>
                    const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
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
                    widget.userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 16, color: Colors.yellow.withOpacity(0.9)),
              const SizedBox(width: 6),
              Text(
                'Premium Member',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? theme.primaryColor.withOpacity(0.8)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
