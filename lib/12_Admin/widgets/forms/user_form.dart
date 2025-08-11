import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserForm extends StatefulWidget {
  final User? user;

  const UserForm({super.key, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _role;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.firstName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _role = widget.user?.role ?? 'Member';
    _status = widget.user?.status ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _role,
            items: ['Super Admin', 'Admin', 'Moderator', 'Farmer', 'Guest']
                .map((role) => DropdownMenuItem(
              value: role,
              child: Text(role),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _role = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          DropdownButtonFormField<String>(
            value: _status,
            items: ['Active', 'Inactive', 'Pending']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Status'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}