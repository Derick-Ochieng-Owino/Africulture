import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPaymentsPage extends StatefulWidget {
  const AdminPaymentsPage({super.key});

  @override
  State<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends State<AdminPaymentsPage> {
  String _selectedStatus = "all"; // Filter status
  final DateFormat _dateFormat = DateFormat("MMM d, yyyy h:mm a");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💳 Payments Dashboard"),
      ),
      body: Column(
        children: [
          // 🔽 Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "all", child: Text("All")),
                DropdownMenuItem(value: "successful", child: Text("Successful")),
                DropdownMenuItem(value: "failed", child: Text("Failed")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? "all";
                });
              },
            ),
          ),

          // 🔽 Payments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("payments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading payments"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_selectedStatus == "all") return true;
                  final status = (doc["status"] ?? "").toLowerCase();
                  if (_selectedStatus == "successful") {
                    return status == "successful" || doc["success"] == true;
                  } else if (_selectedStatus == "failed") {
                    return status == "failed" || doc["success"] == false;
                  }
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No payments found"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final createdAt = data["createdAt"] != null
                        ? (data["createdAt"] as Timestamp).toDate()
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: data["success"] == true
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            data["success"] == true
                                ? Icons.check
                                : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          "${data["userName"] ?? "Unknown"} - ${data["currency"] ?? ""} ${data["amount"] ?? "0"}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${data["email"] ?? "N/A"}"),
                            Text("Phone: ${data["phone"] ?? "N/A"}"),
                            if (createdAt != null)
                              Text("Date: ${_dateFormat.format(createdAt)}"),
                            Text("TxRef: ${data["txRef"]}"),
                          ],
                        ),
                        trailing: Text(
                          data["status"] ?? "unknown",
                          style: TextStyle(
                            color: data["success"] == true
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
