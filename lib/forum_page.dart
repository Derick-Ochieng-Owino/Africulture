import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News"), backgroundColor: Colors.green),
      body: Center(
        child: Text(
          "Latest Agricultural News Here",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
