import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/bottom_navbar.dart';

class OrderHistoryPage extends StatelessWidget {
  final String uid;
  const OrderHistoryPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.orange,
        // Back arrow will appear automatically when using Navigator.push
      ),
      backgroundColor: Colors.teal[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              // Format date if available
              String formattedDate = 'Unknown date';
              if (data['createdAt'] != null) {
                final date = (data['createdAt'] as Timestamp).toDate();
                formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(date);
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['orderStatus']),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(data['orderStatus']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    "Order #${order.id.substring(0, 8)}...",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${data['orderStatus']}"),
                      Text("Payment: ${data['paymentStatus']}"),
                      Text(formattedDate, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Text(
                    "KES ${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    _showOrderDetails(context, order);
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_cart;
    }
  }

  void _showOrderDetails(BuildContext context, DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Order #${order.id.substring(0, 8)}..."),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${data['orderStatus']}"),
            Text("Payment: ${data['paymentStatus']}"),
            Text("Total: KES ${data['totalAmount']?.toStringAsFixed(2)}"),
            if (data['createdAt'] != null)
              Text("Date: ${DateFormat('MMM dd, yyyy').format((data['createdAt'] as Timestamp).toDate())}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}