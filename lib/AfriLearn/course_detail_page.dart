import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEnrolled = false;

  @override
  void initState(){
    super.initState();
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final courseId = widget.course['id'] ?? widget.course['title'];

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('enrollments')
        .doc(courseId)
        .get();

    if (doc.exists) {
      setState(() {
        _isEnrolled = true;
      });
    }
  }

  Future<void> _enrollCourse() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final courseId = widget.course['id'] ?? widget.course['title'];

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('enrollments')
        .doc(courseId)
        .set({
      'courseId': courseId,
      'title': widget.course['title'],
      'description': widget.course['description'],
      'price': widget.course['price'] ?? 'Free',
      'level': widget.course['level'] ?? 'Beginner',
      'duration': widget.course['duration'] ?? 'N/A',
      'certificate': widget.course['certificate'] ?? 'N/A',
      'language': widget.course['language'] ?? 'English',
      'access': widget.course['access'] ?? 'Lifetime',
      'enrolledAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isEnrolled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully enrolled in the course!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEnrollmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enroll in ${widget.course['title']}'),
        content: const Text('You are about to enroll in this course. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _enrollCourse();
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseId = widget.course['id'] ?? widget.course['title'];
    final greenColor = Colors.teal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        backgroundColor: greenColor[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: greenColor[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: greenColor[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course['subTitle'] ??
                        'Technologies, Innovation and Management Practices for Agripreneurs',
                    style: TextStyle(
                      fontSize: 16,
                      color: greenColor[700],
                    ),
                  ),
                ],
              ),
            ),

            // Course Description Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: greenColor[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Target Audience:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: greenColor[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aspiring and practicing agripreneurs, extension service providers, agribusiness startups, youth in agriculture, and development partners promoting agricultural innovation.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: greenColor[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: greenColor[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Course Enrollment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: greenColor[900],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.course['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: greenColor[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Course Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: greenColor[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3,
                    children: [
                      _buildDetailItem('Price', widget.course['price'] ?? 'N/A', Icons.attach_money, Colors.green),
                      _buildDetailItem('Course Level', widget.course['level'] ?? 'N/A', Icons.school, Colors.green),
                      _buildDetailItem('Duration', widget.course['duration'] ?? 'N/A', Icons.schedule, Colors.pink),
                      _buildDetailItem('Certificate', widget.course['certificate'] ?? 'N/A', Icons.card_membership, Colors.yellow),
                      _buildDetailItem('Language', widget.course['language'] ?? 'N/A', Icons.language, Colors.blue),
                      _buildDetailItem('Access', widget.course['access'] ?? 'N/A', Icons.lock_open, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEnrolled) {
                          Navigator.pushNamed(
                              context,
                              '/learn',
                              arguments: courseId,
                          );
                        } else {
                          _showEnrollmentDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEnrolled ? Colors.green : Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEnrolled ? 'Go to Course' : 'Enroll Now',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: greenColor[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Africulture School',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: greenColor[100],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Transforming African agriculture through innovative education and sustainable practices',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Contact: info@africulture.org | +254 740095168',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2025 Africulture School. All Rights Reserved',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailItem(
    String title, String value, IconData icon, MaterialColor greenColor) {
  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: greenColor[200]!),
    ),
    child: Row(
      children: [
        Icon(icon, color: greenColor[700], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: greenColor[700],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
