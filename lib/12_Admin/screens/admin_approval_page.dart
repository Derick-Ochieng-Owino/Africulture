import 'package:africulture/12_Admin/widgets/common/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/common/product_approval_card.dart';

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _selectedProductIds = [];
  bool _isSelecting = false;

  void _toggleSelection(String productId, bool selected) {
    setState(() {
      if (selected) {
        _selectedProductIds.add(productId);
      } else {
        _selectedProductIds.remove(productId);
      }
      _isSelecting = _selectedProductIds.isNotEmpty;
    });
  }

  Future<void> _approveSelected() async {
    if (_selectedProductIds.isEmpty) return;

    final batch = _firestore.batch();
    final userId = _auth.currentUser?.uid ?? 'unknown_user';

    for (final id in _selectedProductIds) {
      final docRef = _firestore.collection('products').doc(id);
      batch.update(docRef, {
        'approved': true,
        'approvedBy': userId,
        'approvedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${_selectedProductIds.length} product(s).')),
    );

    setState(() {
      _selectedProductIds.clear();
      _isSelecting = false;
    });
  }

  Future<void> _rejectSelected() async {
    if (_selectedProductIds.isEmpty) return;

    final batch = _firestore.batch();

    for (final id in _selectedProductIds) {
      final docRef = _firestore.collection('products').doc(id);
      batch.delete(docRef);
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${_selectedProductIds.length} product(s).')),
    );

    setState(() {
      _selectedProductIds.clear();
      _isSelecting = false;
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedProductIds.clear();
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Product Approval',
        myWidget: _isSelecting
            ? Text('${_selectedProductIds.length} selected')
            : const Text('Product Approvals'),
        actions: _isSelecting
            ? [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _approveSelected,
            tooltip: 'Approve Selected',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _rejectSelected,
            tooltip: 'Reject Selected',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelSelection,
            tooltip: 'Cancel Selection',
          ),
        ]
            : [],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('products')
            .where('approved', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading products: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text('No products pending approval.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final productData = doc.data()! as Map<String, dynamic>;
              final productId = doc.id;
              final isSelected = _selectedProductIds.contains(productId);

              return ProductApprovalCard(
                productId: productId,
                productData: productData,
                isSelected: isSelected,
                onSelectionChanged: (selected) => _toggleSelection(productId, selected),
              );
            },
          );
        },
      ),
    );
  }
}