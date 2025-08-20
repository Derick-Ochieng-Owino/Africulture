import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'course_card.dart';
import 'learn_bottomnavbar.dart';
import 'learn_drawer.dart';

class AfriLearnPage extends StatelessWidget {
  const AfriLearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/home');
          },
        ),
        title: Text(translate('learn.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                translate('learn.popular_categories'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryList(),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                translate('learn.featured_courses'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCourseGrid(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade700,
            Colors.teal.shade500,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('learn.welcome'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translate('learn.welcome_description'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(translate('learn.explore_courses')),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'icon': Icons.eco, 'name': 'Crop Farming'},
      {'icon': Icons.agriculture, 'name': 'Livestock'},
      {'icon': Icons.water_drop, 'name': 'Irrigation'},
      {'icon': Icons.biotech, 'name': 'Technology'},
      {'icon': Icons.business_center, 'name': 'Agribusiness'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category['icon'] as IconData, color: Colors.teal.shade700, size: 32),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseGrid() {
    final courses = [
      {
        'title': translate('courses.avocado_timps.title'),
        'image': 'assets/learn/avocado.jpg',
        'price': 'Free',
        'level': 'Intermediate',
        'duration': '6 weeks',
        'description': translate('courses.avocado_timps.description'),
        'access': 'Lifetime',
        'language': 'English',
        'certificate': 'Yes',
      },
      {
        'title': translate('courses.beans_timps.title'),
        'image': 'assets/learn/beans.jpg',
        'price': 'Kshs 50',
        'level': 'Beginner',
        'duration': '4 weeks',
        'description': translate('courses.beans_timps.description'),
        'access': 'Lifetime',
        'language': 'English',
        'certificate': 'Yes',
      },
      {
        'title': translate('courses.apiculture.title'),
        'image': 'assets/learn/beekeeping.jpg',
        'price': 'Kshs 50',
        'level': 'Intermediate',
        'duration': '8 weeks',
        'description': translate('courses.apiculture.description'),
        'access': 'Lifetime',
        'language': 'English',
        'certificate': 'Yes',
      },
      {
        'title': translate('courses.mango_timps.title'),
        'image': 'assets/learn/mango.jpg',
        'price': 'Free',
        'level': 'Intermediate',
        'duration': '5 weeks',
        'description': translate('courses.mango_timps.description'),
        'access': 'Lifetime',
        'language': 'English',
        'certificate': 'Yes',
      },
      {
        'title': translate('courses.dairy_timps.title'),
        'image': 'assets/learn/dairy.jpg',
        'price': 'Kshs 50',
        'level': 'Advanced',
        'duration': '10 weeks',
        'description': translate('courses.dairy_timps.description'),
        'access': 'Lifetime',
        'language': 'English',
        'certificate': 'Yes',
      },
      {
        'title': translate('courses.maize_timps.title'),
        'image': 'assets/learn/maize.jpg',
        'price': 'Kshs 50',
        'level': 'Beginner',
        'duration': '4 weeks',
        'description': translate('courses.maize_timps.description'),
        'access': 'Lifetime',
        'language': 'English',
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
}