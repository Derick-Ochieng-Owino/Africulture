import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final String level;
  final String duration;
  final String description;
  final String access;
  final String certificate;
  final String language;

  const CourseCard({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.level,
    required this.duration,
    required this.description,
    required this.access,
    required this.certificate,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(context, '/course_detail', arguments: {
            'title': title,
            'image': image,
            'price': price,
            'level': level,
            'duration': duration,
            'description': description,
            'access': access,
            'certificate': certificate,
            'language': language,
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 400) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.asset(
                      image,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(child: _buildDetails(context)),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildDetails(context),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// Shared details widget
  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // Rating + Duration
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade700, size: 14),
            const SizedBox(width: 4),
            Text('4.8',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            Icon(Icons.schedule, color: Colors.grey.shade600, size: 14),
            const SizedBox(width: 4),
            Text(duration,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),

        const SizedBox(height: 6),

        // Description preview
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),

        const SizedBox(height: 8),

        // Level + Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                level,
                style: TextStyle(fontSize: 10, color: Colors.green.shade700),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: price == 'Free'
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
