import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Market"), backgroundColor: Colors.green),
      body: Center(
        child: Text(
          "Market Page Content Here",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
