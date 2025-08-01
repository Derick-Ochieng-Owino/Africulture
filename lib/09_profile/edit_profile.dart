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
  final _farmingTypeController = TextEditingController();

  // Kenya location data
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedVillage;

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  // Sample Kenya locations (replace with complete data)
  final Map<String, Map<String, List<String>>> _kenyaLocations = {
    'Nairobi': {
      'Westlands': ['Lavington', 'Kitisuru', 'Parklands'],
      'Dagoretti': ['Ngando', 'Riruta', 'Uthiru'],
      'Embakasi': ['Pipeline', 'Umoja', 'Donholm'],
      'Kasarani': ['Mwiki', 'Githurai', 'Clay City'],
    },
    'Mombasa': {
      'Nyali': ['Kongowea', 'Mkomani', 'Bamburi'],
      'Kisauni': ['Mtopanga', 'Mjambere', 'Bamburi'],
      'Changamwe': ['Port Reitz', 'Changamwe', 'Airport'],
      'Likoni': ['Shika Adabu', 'Likoni', 'Mtongwe'],
    },
    'Kakamega': {
      'Lurambi': ['Mahiakalo', 'Lurambi', 'Butsotso'],
      'Malava': ['Malava', 'Chegulo', 'Kabras'],
      'Mumias West': ['Musanda', 'Shibinga', 'Etenje'],
      'Butere': ['Bukura', 'Shikunga', 'Marama West'],
    },
    'Kiambu': {
      'Ruiru': ['Gatongora', 'Mugutha', 'Biashara'],
      'Thika Town': ['Township', 'Kamenu', 'Hospital'],
      'Kikuyu': ['Kikuyu', 'Sigona', 'Karai'],
    },
    'Kisumu': {
      'Kisumu Central': ['Market Milimani', 'Nyalenda', 'Railways'],
      'Nyando': ['Ahero', 'Kobura', 'Awasi'],
      'Seme': ['East Seme', 'West Seme', 'North Seme'],
    },
    'Nakuru': {
      'Naivasha': ['Lake View', 'Mai Mahiu', 'Karagita'],
      'Nakuru Town East': ['Flamingo', 'Menengai', 'Biashara'],
      'Rongai': ['Visoi', 'Londiani', 'Soin'],
    },
    'Uasin Gishu': {
      'Eldoret East': ['Kapsoya', 'Chepkoilel', 'Simat'],
      'Turbo': ['Turbo', 'Kamukunji', 'Huruma'],
    },
    'Meru': {
      'Imenti North': ['Municipality', 'Ntima East', 'Ntima West'],
      'Tigania West': ['Kianjai', 'Muthara', 'Athwana'],
    },
  };


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(widget.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _selectedCounty = data['county'];
        _selectedSubCounty = data['subCounty'];
        _selectedVillage = data['village'];
        _farmingTypeController.text = data['farmingType'] ?? '';
        _existingImageUrl = data['imageUrl'];
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final imageFile = File(pickedFile.path);
      setState(() => _selectedImage = imageFile);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.uid}.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.uid)
          .update({'imageUrl': downloadUrl});

      setState(() {
        _existingImageUrl = downloadUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.uid)
          .set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'county': _selectedCounty,
        'subCounty': _selectedSubCounty,
        'village': _selectedVillage,
        'farmingType': _farmingTypeController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_existingImageUrl != null
                          ? NetworkImage(_existingImageUrl!)
                          : const AssetImage('assets/back_images/default_profile.jpg') as ImageProvider),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCounty,
                decoration: const InputDecoration(labelText: 'County'),
                items: _kenyaLocations.keys.map((String county) {
                  return DropdownMenuItem<String>(
                    value: county,
                    child: Text(county),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCounty = newValue;
                    _selectedSubCounty = null;
                    _selectedVillage = null;
                  });
                },
                validator: (value) => value == null ? 'Please select a county' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubCounty,
                decoration: const InputDecoration(labelText: 'Sub-County'),
                items: _selectedCounty != null
                    ? _kenyaLocations[_selectedCounty]!.keys.map((String subCounty) {
                  return DropdownMenuItem<String>(
                    value: subCounty,
                    child: Text(subCounty),
                  );
                }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubCounty = newValue;
                    _selectedVillage = null;
                  });
                },
                validator: (value) => value == null ? 'Please select a sub-county' : null,
                disabledHint: const Text('Select county first'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVillage,
                decoration: const InputDecoration(labelText: 'Village'),
                items: _selectedCounty != null && _selectedSubCounty != null
                    ? _kenyaLocations[_selectedCounty]![_selectedSubCounty]!
                    .map((String village) {
                  return DropdownMenuItem<String>(
                    value: village,
                    child: Text(village),
                  );
                }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVillage = newValue;
                  });
                },
                disabledHint: const Text('Select sub-county first'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _farmingTypeController,
                decoration: const InputDecoration(labelText: 'Type of Farming'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}