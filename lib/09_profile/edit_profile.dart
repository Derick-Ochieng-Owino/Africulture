import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countyController = TextEditingController();
  final _subCountyController = TextEditingController();
  final _villageController = TextEditingController();
  final _farmingTypeController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _countyController.text = data['county'] ?? '';
      _subCountyController.text = data['subcounty'] ?? '';
      _villageController.text = data['village'] ?? '';
      _farmingTypeController.text = data['farmingType'] ?? '';
      _existingImageUrl = data['imageUrl'];
      setState(() {}); // refresh UI
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      debugPrint("❌ No image selected");
      return;
    }

    try {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImage = imageFile;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.uid}.jpg');

      debugPrint("⏳ Uploading to Firebase Storage...");
      final uploadTask = await storageRef.putFile(imageFile);

      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        debugPrint("✅ Image uploaded! URL: $downloadUrl");

        await FirebaseFirestore.instance
            .collection('farmers')
            .doc(widget.uid)
            .update({'imageUrl': downloadUrl});
        debugPrint("✅ imageUrl field updated in Firestore");

        setState(() {
          _existingImageUrl = downloadUrl;
        });
      } else {
        debugPrint("❌ Upload failed: ${uploadTask.state}");
      }
    } catch (e) {
      debugPrint("❌ Upload error: $e");
    }
  }



  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'county': _countyController.text.trim(),
      'subcounty': _subCountyController.text.trim(),
      'village': _villageController.text.trim(),
      'farmingType': _farmingTypeController.text.trim(),
    }, SetOptions(merge: true));

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_existingImageUrl != null
                          ? NetworkImage(_existingImageUrl!) as ImageProvider
                          : const AssetImage('assets/placeholder.png')),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              ),
              TextFormField(
                controller: _subCountyController,
                decoration: const InputDecoration(labelText: 'Sub-county'),
              ),
              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(labelText: 'Village'),
              ),
              TextFormField(
                controller: _farmingTypeController,
                decoration: const InputDecoration(labelText: 'Type of Farming'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
