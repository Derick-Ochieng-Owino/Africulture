import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminApprovalPage extends StatelessWidget {
  const AdminApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body: StreamBuilder(
        stream: productsRef.where('approved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending products"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return ListTile(
                title: Text(data['name']),
                subtitle: Text("KES ${data['price']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    productsRef.doc(doc.id).update({'approved': true});
                  },
                  child: const Text("Approve"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
