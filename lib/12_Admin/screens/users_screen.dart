import 'package:africulture/12_Admin/widgets/common/app_bar.dart';
import 'package:africulture/12_Admin/widgets/common/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/data/data_table_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _showOnlineOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateUserOnlineStatus(true);
      userProvider.loadAllUsers();
    });
  }

  @override
  void dispose() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserOnlineStatus(false);

    super.dispose();
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    print('User in edit dialog: $user');
    final _roleController = TextEditingController(text: (user['userType'] ?? '').toString());
    final _statusController = TextEditingController(text: (user['status'] ?? '').toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${(user['firstName'] ?? '')} ${(user['lastName'] ?? '')}'),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRole = _roleController.text.trim();
              final newStatus = _statusController.text.trim();

              if (newRole.isEmpty || newStatus.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role and Status cannot be empty')),
                );
                return;
              }

              try {
                await Provider.of<UserProvider>(context, listen: false)
                    .updateUserRoleStatus(user['id'], newRole, newStatus);

                await Provider.of<UserProvider>(context, listen: false).loadAllUsers();

                Navigator.of(ctx).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update user: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Apply online filter and search filter
    final filteredUsers = userProvider.users.where((user) {
      final matchesOnline = _showOnlineOnly ? (user['isOnline'] == true) : true;
      final matchesSearch = _searchQuery.isEmpty ||
          (user['firstName'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user['email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesOnline && matchesSearch;
    }).toList();

    return Scaffold(
      drawer: AdminDrawer(
        userName: 'firstName',
        userEmail: 'email',
        profileImageUrl: 'profileImageUrl',
        location: 'location',
      ),
      appBar: AdminAppBar(title: 'User Management'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showOnlineOnly = !_showOnlineOnly;
                    });
                  },
                  child: Text(_showOnlineOnly ? 'Show All Users' : 'Show Online Users'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DataTableWidget(
                columns: const ['ID', 'First Name', 'Second Name','Email', 'Role', 'Status', 'Online', 'Actions'],
                rows: filteredUsers.map((user) {
                  return {
                    'ID': user['id'] ?? '',
                    'First Name': user['firstName'] ?? '',
                    'Second Name': user['lastName'] ?? '',
                    'Email': user['email'] ?? '',
                    'Role': user['userType'] ?? '',
                    'Status': user['status'] ?? '',
                    'Online': user['isOnline'] ?? false,
                    'id': user['id'] ?? '',
                    'firstName': user['firstName'] ?? '',
                    'lastName': user['lastName'] ?? '',
                    'userType': user['userType'] ?? '',
                    'status': user['status'] ?? '',
                  };
                }).toList(),
                onEdit: (user) {
                  _showEditUserDialog(user);
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
