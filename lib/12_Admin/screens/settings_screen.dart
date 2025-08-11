import 'package:africulture/12_Admin/widgets/common/app_bar.dart';
import 'package:africulture/12_Admin/widgets/common/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: AdminDrawer(userName: 'userName', userEmail: 'userEmail', profileImageUrl: 'profileImageUrl', location: 'location'),
      appBar: AdminAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Appearance', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                    const Divider(),
                    const Text('Language', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: 'English',
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Spanish',
                          child: Text('Spanish'),
                        ),
                        DropdownMenuItem(
                          value: 'French',
                          child: Text('French'),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notifications', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      value: true,
                      onChanged: (value) {},
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      value: true,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
