import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

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
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
          ),
        ],
      ),
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
                // Profile Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularPercentIndicator(
                              radius: 60,
                              lineWidth: 8,
                              percent: profileCompletion,
                              progressColor: Colors.green[800],
                              //backgroundColor: Colors.green[100],
                              circularStrokeCap: CircularStrokeCap.round,
                              center: CircleAvatar(
                                radius: 50,
                                backgroundImage: data['imageUrl'] != null
                                    ? NetworkImage(data['imageUrl'])
                                    : null,
                                backgroundColor: Colors.green[100],
                                child: data['imageUrl'] == null
                                    ? const Icon(Icons.person,
                                    size: 40, color: Colors.green)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[800],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(profileCompletion * 100).toStringAsFixed(0)}% Complete',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data['name'] ?? 'No Name',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                        if (data['farmingType'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Chip(
                              label: Text(data['farmingType']!),
                              backgroundColor: Colors.green[50],
                              labelStyle: const TextStyle(color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Details Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildProfileRow(Icons.phone, 'Phone', data['phone']),
                        _buildProfileRow(
                            Icons.location_on, 'County', data['county']),
                        _buildProfileRow(Icons.location_city, 'Sub-county',
                            data['subcounty']),
                        _buildProfileRow(
                            Icons.home, 'Village', data['village']),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Call-to-action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Complete Your Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildProfileRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey)),
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