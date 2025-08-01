import 'dart:io' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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
  final _farmingTypeController = TextEditingController();
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedVillage;
  bool _isLoading = false;

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


  File? _image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _selectedCounty = data['county'];
        _selectedSubCounty = data['subCounty'];
        _selectedVillage = data['village'];
        _farmingTypeController.text = data['farmingType'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadImage(dynamic imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/${widget.uid}.jpg');

    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(imageFile as Uint8List);
    } else {
      uploadTask = ref.putFile(imageFile as io.File);
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  double _calculateCompleteness() {
    int totalFields = 6;
    int filled = 0;

    if (_nameController.text.isNotEmpty) filled++;
    if (_phoneController.text.isNotEmpty) filled++;
    if (_selectedCounty?.isNotEmpty ?? false) filled++;
    if (_selectedSubCounty?.isNotEmpty ?? false) filled++;
    if (_selectedVillage?.isNotEmpty ?? false) filled++;
    if (_image != null) filled++;

    return filled / totalFields;
  }

  Future<XFile?> compressImage(File file) async {
    print(FirebaseAuth.instance.currentUser?.uid);
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/temp_profile_${widget.uid}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );
    return result;
  }

  Future<void> _saveProfile() async {
    print(FirebaseAuth.instance.currentUser?.uid);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl;

    if (_image != null) {
      File? compressedImage = (await compressImage(_image!)) as io.File?;
      if (compressedImage != null) {
        imageUrl = await _uploadImage(compressedImage);
      }
    }

    await FirebaseFirestore.instance.collection('farmers').doc(widget.uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'county': _selectedCounty,
      'subCounty': _selectedSubCounty,
      'village': _selectedVillage,
      'farmingType': _farmingTypeController.text.trim(),
      'profileComplete': _calculateCompleteness() == 1.0,
      if (imageUrl != null) 'photoUrl': imageUrl,
    }, SetOptions(merge: true));

    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
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