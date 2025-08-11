import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? myWidget;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.myWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.orange,
      actions: [
        ...?actions,
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin_Notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin_profile');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}