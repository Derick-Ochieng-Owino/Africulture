import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final bool showAppBar;
  final Color primaryColor;

  const ProfilePage({
    super.key,
    required this.user,
    this.showAppBar = true,
    this.primaryColor = Colors.green,
  });

  Future<Map<String, dynamic>?> fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(user.uid)
        .get();
    return snapshot.data();
  }

  double calculateCompletion(Map<String, dynamic> data) {
    final totalFields = 6;
    int filled = 0;
    if ((data['name'] ?? '').isNotEmpty) filled++;
    if ((data['phone'] ?? '').isNotEmpty) filled++;
    if ((data['county'] ?? '').isNotEmpty) filled++;
    if ((data['subcounty'] ?? '').isNotEmpty) filled++;
    if ((data['village'] ?? '').isNotEmpty) filled++;
    if ((data['farmingType'] ?? '').isNotEmpty) filled++;
    return filled / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/edit_profile'),
          ),
        ],
      )
          : null,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data found"));
          }

          final data = snapshot.data!;
          final profileCompletion = calculateCompletion(data);
          final theme = Theme.of(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Image + Completion Bar
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: data['imageUrl'] != null
                          ? NetworkImage(data['imageUrl'])
                          : null,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: data['imageUrl'] == null
                          ? Icon(Icons.person,
                          size: 50, color: primaryColor)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['name'] ?? 'No Name',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (data['farmingType'] != null &&
                        (data['farmingType'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Chip(
                          label: Text(data['farmingType']),
                          backgroundColor: primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(color: primaryColor),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: profileCompletion,
                        minHeight: 10,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${(profileCompletion * 100).toStringAsFixed(0)}% Complete",
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Personal Info
                _buildInfoCard(
                  title: "Personal Information",
                  children: [
                    _buildProfileRow(
                        Icons.phone, 'Phone', data['phone'], primaryColor),
                    _buildProfileRow(
                        Icons.location_on, 'County', data['county'], primaryColor),
                    _buildProfileRow(Icons.location_city, 'Sub-county',
                        data['subcounty'], primaryColor),
                    _buildProfileRow(
                        Icons.home, 'Village', data['village'], primaryColor),
                  ],
                ),

                const SizedBox(height: 20),

                // Complete Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Complete Your Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/edit_profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(
      IconData icon, String label, String? value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                    const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value ?? 'Not specified',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
