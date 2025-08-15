import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String searchQuery = "";
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void replayTutorial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tutorial replay started"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Implement your tutorial replay logic here
  }

  Future<void> submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Please sign in to submit a support ticket"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("support_tickets").add({
        "userId": user?.uid ?? "guest",
        "email": user?.email ?? "guest@example.com",
        "subject": _subjectController.text,
        "description": _descriptionController.text,
        "createdAt": FieldValue.serverTimestamp(),
        "status": "pending",
      });

      _subjectController.clear();
      _descriptionController.clear();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Ticket submitted successfully!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Error submitting ticket: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'derickochiengowino@gmail.com',
      queryParameters: {
        'subject': 'App Support Request',
        'body': 'Hello Support Team,\n\nI need help with...',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not launch email client"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+254740095168';
    final url = Uri.parse("https://wa.me/$phoneNumber?text=Hello%20Support");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not launch WhatsApp"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search help topics...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // FAQ Section
              const Text(
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("faqs").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  final faqs = snapshot.data!.docs.where((doc) {
                    final question = doc["question"].toString().toLowerCase();
                    final answer = doc["answer"].toString().toLowerCase();
                    return question.contains(searchQuery) ||
                        answer.contains(searchQuery);
                  }).toList();

                  if (faqs.isEmpty) {
                    return Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          "No matching help topics found",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: faqs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final doc = faqs[index];
                      return ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          doc["question"],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              doc["answer"],
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.play_circle_outline, size: 20),
                    label: const Text("Replay Tutorial"),
                    onPressed: replayTutorial,
                    backgroundColor: Colors.orange[50],
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.help_outline, size: 20),
                    label: const Text("View Guides"),
                    onPressed: () {
                      // Navigate to guides page
                    },
                    backgroundColor: Colors.blue[50],
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.feedback_outlined, size: 20),
                    label: const Text("Send Feedback"),
                    onPressed: () {
                      // Navigate to feedback page
                    },
                    backgroundColor: Colors.green[50],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Support Section
              const Text(
                "Contact Support",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.red),
                        title: const Text("Email Support"),
                        subtitle: const Text("Typically responds within 24 hours"),
                        onTap: _launchEmail,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.chat, color: Colors.green),
                        title: const Text("WhatsApp Chat"),
                        subtitle: const Text("Instant messaging support"),
                        onTap: _launchWhatsApp,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Report Problem Section
              const Text(
                "Report a Problem",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: "Subject",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe your issue';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitTicket,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Submit Ticket",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}