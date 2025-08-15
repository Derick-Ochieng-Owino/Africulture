import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  final String uid;
  const OrderHistoryPage({super.key,  required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History"), backgroundColor: Colors.orange,),
      backgroundColor: Colors.teal[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Order: ${order.id}"),
                  subtitle: Text(
                    "Status: ${order['orderStatus']} | Payment: ${order['paymentStatus']}",
                  ),
                  trailing: Text("KES ${order['totalAmount']}"),
                  onTap: () {
                    // Show detailed order page
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
