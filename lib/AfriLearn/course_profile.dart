import 'package:flutter/material.dart';

import 'learn_bottomnavbar.dart';

class CourseProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile and Courses'),
      ),
      body: Container(

      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

}