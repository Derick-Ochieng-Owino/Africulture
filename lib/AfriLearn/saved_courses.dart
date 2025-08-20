import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'learn_bottomnavbar.dart';

class SavedCourses extends StatelessWidget {
  const SavedCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to view enrolled courses."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Center(
          child: Text(
            'Enrolled Courses',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('enrollments')
            .orderBy('enrolledAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No enrolled courses yet.'),
            );
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final doc = courses[index];
              final course = doc.data() as Map<String, dynamic>;
              final courseId = course['courseId'] ?? '';
              final isComplete = course['isComplete'] ?? false;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & description at the top
                      Text(
                        course['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(course['description'] ?? 'No Description'),

                      const SizedBox(height: 16),

                      // Buttons below
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/learn',
                                arguments: courseId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: const Text(
                              "Go to Course",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('enrollments')
                                  .doc(doc.id)
                                  .update({'isComplete': !isComplete});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              isComplete ? Colors.green : Colors.red,
                            ),
                            child: Text(
                              isComplete ? "Complete" : "Incomplete",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}
