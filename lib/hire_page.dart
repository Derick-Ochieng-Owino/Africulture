import 'package:flutter/material.dart';

class HirePage extends StatelessWidget {
  const HirePage({super.key});

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
