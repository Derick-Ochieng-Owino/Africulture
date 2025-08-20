import 'package:flutter/material.dart';

class LearningPage extends StatelessWidget {
  final String courseId;

  const LearningPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    Widget courseContent;

    switch (courseId.toLowerCase()) {
      case "apiculture":
        courseContent = _buildApicultureModule();
        break;
      case "horticulture":
        courseContent = _buildHorticultureModule();
        break;
      case "aquaculture":
        courseContent = _buildAquacultureModule();
        break;
      default:
        courseContent = Center(
          child: Text("Course module for '$courseId' is not available."),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(courseId, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courseContent,
      ),
    );
  }

  // Example Apiculture module
  Widget _buildApicultureModule() {
    return ListView(
      children: const [
        Text(
          "Apiculture (Beekeeping) Module",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "1. Introduction to Apiculture\n"
              "   - Importance of bees in agriculture and pollination.\n"
              "   - History of beekeeping.\n\n"
              "2. Beehive Management\n"
              "   - Types of hives: Langstroth, Kenyan Top Bar, Traditional Log.\n"
              "   - Hive placement and maintenance.\n\n"
              "3. Bee Species & Behavior\n"
              "   - Common bee species.\n"
              "   - Life cycle of a bee colony.\n\n"
              "4. Honey Production & Harvesting\n"
              "   - Extracting honey safely.\n"
              "   - Processing and packaging.\n\n"
              "5. Diseases & Pests\n"
              "   - Common threats (Varroa mites, wax moths).\n"
              "   - Prevention and treatment.\n\n"
              "6. Economics of Beekeeping\n"
              "   - Cost-benefit analysis.\n"
              "   - Market opportunities.",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Example Horticulture module
  Widget _buildHorticultureModule() {
    return ListView(
      children: const [
        Text(
          "Horticulture Module",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "1. Introduction to horticulture\n"
              "2. Crop selection and soil preparation\n"
              "3. Irrigation and fertilization\n"
              "4. Pest and disease control\n"
              "5. Harvesting and post-harvest handling",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Example Aquaculture module
  Widget _buildAquacultureModule() {
    return ListView(
      children: const [
        Text(
          "Aquaculture Module",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "1. Introduction to aquaculture\n"
              "2. Fish species selection\n"
              "3. Pond/tank construction and management\n"
              "4. Feeding and growth monitoring\n"
              "5. Disease prevention\n"
              "6. Harvesting techniques",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
