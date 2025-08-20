import 'package:flutter/material.dart';
import 'course_card.dart';
import 'learn_bottomnavbar.dart';
import 'learn_drawer.dart';

class CoursesPage extends StatelessWidget {
  CoursesPage({super.key});

  final List<Map<String, dynamic>> courses = [
    {
      'title': 'Agricultural TIMPs',
      'description': 'Learn proven agricultural technologies and innovations...',
      'price': 'Free',
      'level': 'Intermediate',
      'duration': '9 weeks',
      'certificate': 'Yes',
      'language': 'English',
      'access': 'Lifetime',
    },
    {
      'title': 'Avocado TIMPs',
      'description': 'Deep dive into Avocado value chain and farming practices...',
      'price': 'Kshs 50',
      'level': 'Beginner',
      'duration': '6 weeks',
      'certificate': 'Yes',
      'language': 'English',
      'access': '1 year',
    },
    // ✅ Add more courses
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Center(child: Text("Courses", style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCourseGrid(),
              const Text(
                'Section Outline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionItem(
                context,
                'General',
                [
                  'Announcements Forum',
                  'Introduction to Agricultural TIMPs',
                  'Background Information Book'
                ],
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Avocado TIMPs',
                _generateModules(8, 'Avocado'),
                Colors.teal,
                courses[1],
              ),
              _buildSectionItem(
                context,
                'Beans TIMPs',
                _generateModules(8, 'Beans'),
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Apiculture TIMPS',
                [
                  'Understanding the Bee Value Chain',
                  'Breed Selection',
                  'Breeding Approaches in Bee farming',
                  'Forage Production'
                ],
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Mango TIMPs',
                _generateModules(8, 'Mango'),
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Maize TIMPs',
                _generateModules(8, 'Maize'),
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Cashew Nut TIMPs',
                _generateModules(8, 'Cashew Nut'),
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Chicken TIMPs',
                [
                  'Understanding the Chicken Farming Value Chain',
                  'Selecting the Appropriate Breeds For Chicken Farming',
                  'Housing and Infrastructure for Dairy Farming'
                ],
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Dairy TIMPs',
                [
                  'Understanding the Dairy Value Chain',
                  'Selecting the Appropriate Breeds For Dairy Farming',
                  'Housing and Infrastructure for Dairy Farming'
                ],
                Colors.teal,
                courses[0],
              ),
              _buildSectionItem(
                context,
                'Natural Resource Management TIMPs',
                [],
                Colors.teal,
                courses[0],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}

/// Generate placeholder modules
List<String> _generateModules(int count, String crop) {
  return List.generate(count, (index) {
    switch (index) {
      case 0:
        return 'Module ${index + 1}: Understanding the $crop Value Chain';
      case 1:
        return 'Module ${index + 1}: Seed Selection';
      case 2:
        return 'Module ${index + 1}: Land Preparation and Planting';
      case 3:
        return 'Module ${index + 1}: Agronomic Practices/Crop Management';
      case 4:
        return 'Module ${index + 1}: Water and Irrigation Management';
      case 5:
        return 'Module ${index + 1}: Pest and Disease Management';
      case 6:
        return 'Module ${index + 1}: Harvesting and Post-Harvest Practices';
      case 7:
        return 'Module ${index + 1}: Value Addition and Marketing';
      default:
        return 'Module ${index + 1}: $crop TIMPs';
    }
  });
}

/// Fixed: accepts `Color` not `MaterialColor`
Widget _buildSectionItem(
    BuildContext context,
    String title,
    List<String> items,
    Color color,
    Map<String, dynamic> course,
    ) {
  return ExpansionTile(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
    children: items
        .map(
          (item) => ListTile(
        leading: Icon(Icons.library_books, size: 20, color: color),
        title: Text(item),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/course_detail',
            arguments: {
              ...course, // pass course details
              'module': item, // also pass clicked module
            },
          );
        },
      ),
    )
        .toList(),
  );
}

Widget _buildCourseGrid() {
  final courses = [
    {
      'title': 'Avocado TIMPs',
      'image': 'assets/learn/avocado.jpg',
      'price': 'Free',
      'level': 'Intermediate',
      'duration': '6 weeks',
      'description': 'Learn modern avocado farming techniques, value chain development, and export market strategies.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
    {
      'title': 'Beans TIMPs',
      'image': 'assets/learn/beans.jpg',
      'price': 'Kshs 50',
      'level': 'Beginner',
      'duration': '4 weeks',
      'description': 'Master bean cultivation, pest management, and high-yield production methods.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
    {
      'title': 'Apiculture',
      'image': 'assets/learn/beekeeping.jpg',
      'price': 'Kshs 50',
      'level': 'Intermediate',
      'duration': '8 weeks',
      'description': 'Discover sustainable beekeeping practices, honey production, and hive management.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
    {
      'title': 'Mango TIMPs',
      'image': 'assets/learn/mango.jpg',
      'price': 'Free',
      'level': 'Intermediate',
      'duration': '5 weeks',
      'description': 'Learn mango cultivation, value addition, and export quality production techniques.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
    {
      'title': 'Dairy TIMPs',
      'image': 'assets/learn/dairy.jpg',
      'price': 'Kshs 50',
      'level': 'Advanced',
      'duration': '10 weeks',
      'description': 'Master dairy farming, animal health, milk production, and processing.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
    {
      'title': 'Maize TIMPs',
      'image': 'assets/learn/maize.jpg',
      'price': 'Kshs 50',
      'level': 'Beginner',
      'duration': '4 weeks',
      'description': 'Learn modern maize farming techniques for higher yields and profitability.',
      'access': 'Lifetime',
      'language': 'English/Kiswahili',
      'certificate': 'Yes',
    },
  ];

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: courses.length,
    itemBuilder: (context, index) {
      final course = courses[index];
      return CourseCard(
        title: course['title'] as String,
        image: course['image'] as String,
        price: course['price'] as String,
        level: course['level'] as String,
        duration: course['duration'] as String,
        description: course['description'] as String,
        access: course['access'] as String,
        certificate: course['certificate'] as String,
        language: course['language'] as String,
      );
    },
  );
}