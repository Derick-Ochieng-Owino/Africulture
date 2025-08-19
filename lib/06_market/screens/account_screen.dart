import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navbar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    //final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.teal[50],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal,
            child: user?.photoURL != null
                ? ClipOval(
              child: Image.network(
                user!.photoURL!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
                : const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.displayName ?? 'User Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  user!.email!,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          _buildAccountSection(context),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        _buildAccountTile(
          icon: Icons.person_outline,
          title: 'Personal Information',
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        _buildAccountTile(
          icon: Icons.location_on_outlined,
          title: 'Shipping Addresses',
          onTap: () {},
        ),
        _buildAccountTile(
          icon: Icons.payment_outlined,
          title: 'Payment Methods',
          onTap: () {},
        ),
        _buildAccountTile(
          icon: Icons.history,
          title: 'Order History',
          onTap: () {}, // Implement order history
        ),
        const SizedBox(height: 24),
        _buildSignOutButton(context),
      ],
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _showSignOutConfirmation(context, authService),
        child: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showSignOutConfirmation(
      BuildContext context, AuthService authService) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}