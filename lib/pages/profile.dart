import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '/pages/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  Future<Map<String, dynamic>?> fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance.collection('farmers').doc(user.uid).get();
    return snapshot.data();
  }

  double calculateCompletion(Map<String, dynamic> data) {
    final totalFields = 6; // total editable fields
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
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>?> (
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No user data found."));
            }
            final data = snapshot.data!;
            final profileCompletion = calculateCompletion(data);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 8.0,
                    percent: profileCompletion,
                    center: Text("${(profileCompletion * 100).toStringAsFixed(0)}%"),
                    progressColor: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: data['imageUrl'] != null
                        ? NetworkImage(data['imageUrl'])
                        : null,
                    backgroundColor: Colors.green,
                    child: data['imageUrl'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  profileField("Name", data['name']),
                  profileField("Phone", data['phone']),
                  profileField("County", data['county']),
                  profileField("Sub-county", data['subcounty']),
                  profileField("Village", data['village']),
                  profileField("Farming Type", data['farmingType']),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget profileField(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value ?? 'Not set'),
        ),
      ],
    );
  }
}