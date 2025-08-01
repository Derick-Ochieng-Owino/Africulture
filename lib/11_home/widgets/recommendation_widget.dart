import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final Color color;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    this.color = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class RecommendationsList extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final Color? iconColor;

  const RecommendationsList({
    super.key,
    required this.recommendations,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: recommendations.map((recommendation) =>
            RecommendationCard(
              title: recommendation['title'],
              icon: recommendation['icon'],
              subtitle: recommendation['subtitle'],
              color: Colors.blueGrey,
            )
        ).toList(),
      ),
    );
  }
}