import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';



class UserProfileModal extends StatefulWidget {
  final String uid;

  const UserProfileModal({super.key, required this.uid});

  @override
  State<UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends State<UserProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countyController = TextEditingController();
  final _subCountyController = TextEditingController();
  final _villageController = TextEditingController();
  final _farmingTypeController = TextEditingController();

  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _countyController.text = data['county'] ?? '';
      _subCountyController.text = data['subCounty'] ?? '';
      _villageController.text = data['village'] ?? '';
      _farmingTypeController.text = data['farmingType'] ?? '';
      // optionally preload image url
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/${widget.uid}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  double _calculateCompleteness() {
    int totalFields = 6;
    int filled = 0;

    if (_nameController.text.isNotEmpty) filled++;
    if (_phoneController.text.isNotEmpty) filled++;
    if (_countyController.text.isNotEmpty) filled++;
    if (_subCountyController.text.isNotEmpty) filled++;
    if (_villageController.text.isNotEmpty) filled++;
    if (_image != null) filled++;

    return filled / totalFields;
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/temp_profile_${widget.uid}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );
    return null;
  }


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl;

    // 🔽 Upload image if selected
    if (_image != null) {
      File? compressedImage = await compressImage(_image!);
      if (compressedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${widget.uid}.jpg');

        await ref.putFile(compressedImage);
        imageUrl = await ref.getDownloadURL();
      }
    }

    //Save all details to firebase
    await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'county': _countyController.text.trim(),
      'subCounty': _subCountyController.text.trim(),
      'village': _villageController.text.trim(),
      'farmingType': _farmingTypeController.text.trim(),
      'profileComplete': _calculateCompleteness() == 1.0,
      if (imageUrl != null) 'photoUrl': imageUrl,
    }, SetOptions(merge: true));

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    final percent = _calculateCompleteness();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 8.0,
              percent: percent,
              center: Text("${(percent * 100).toStringAsFixed(0)}%"),
              progressColor: Colors.green,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _countyController,
                    decoration: const InputDecoration(labelText: 'County'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _subCountyController,
                    decoration: const InputDecoration(labelText: 'Sub-county'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _villageController,
                    decoration: const InputDecoration(labelText: 'Village'),
                  ),
                  TextFormField(
                    controller: _farmingTypeController,
                    decoration: const InputDecoration(labelText: 'Type of Farming'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}