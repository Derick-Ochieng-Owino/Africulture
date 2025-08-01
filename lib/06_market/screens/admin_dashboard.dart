import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../widgets/product_approval_card.dart';
import '../widgets/product_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _selectedIds = [];
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? Text('${_selectedIds.length} selected')
            : const Text('Admin Dashboard'),
        actions: [
          if (_isSelecting) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _approveSelected,
              tooltip: 'Approve selected',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _rejectSelected,
              tooltip: 'Reject selected',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelSelection,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Pending Approval'),
                Tab(text: 'Approved Products'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingApprovalList(),
                  _buildApprovedProductsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('products')
          .where('approved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(child: Text('No products pending approval'));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductApprovalCard(
              productId: product.id,
              productData: product.data() as Map<String, dynamic>,
              isSelected: _selectedIds.contains(product.id),
              onSelectionChanged: _handleSelection,
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('products')
          .where('approved', isEqualTo: true)
          .orderBy('approvedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: Product.fromFirestore(product),
              onTap: () => _showProductDetails(product.id),
              isAdminView: true,
              isSelected: _selectedIds.contains(product.id),
              onSelectionChanged: (selected) => _handleSelection(product.id, selected),
            );

          },
        );
      },
    );
  }

  void _handleSelection(String productId, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(productId);
      } else {
        _selectedIds.remove(productId);
      }
      _isSelecting = _selectedIds.isNotEmpty;
    });
  }

  Future<void> _approveSelected() async {
    if (_selectedIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final userId = _auth.currentUser!.uid;

      for (var id in _selectedIds) {
        final ref = _firestore.collection('products').doc(id);
        batch.update(ref, {
          'approved': true,
          'approvedBy': userId,
          'approvedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approved ${_selectedIds.length} products')),
      );

      _cancelSelection();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectSelected() async {
    if (_selectedIds.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (var id in _selectedIds) {
        final ref = _firestore.collection('products').doc(id);
        batch.delete(ref);
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected ${_selectedIds.length} products')),
      );

      _cancelSelection();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: ${e.toString()}')),
      );
    }
  }

  void _cancelSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelecting = false;
    });
  }

  Future<void> _showProductDetails(String productId) async {
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}