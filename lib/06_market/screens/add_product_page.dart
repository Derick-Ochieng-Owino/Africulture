import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'dart:io';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String _category = 'Seeds';
  File? _imageFile;
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0;

  final List<String> _categories = [
    'Seeds', 'Fertilizers', 'Equipment',
    'Tools', 'Pesticides', 'Organic',
    'Livestock', 'Feed', 'Accessories'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final fileSize = await pickedFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          setState(() {
            _error = 'Image too large (max 5MB)';
          });
          return;
        }

        setState(() {
          _imageFile = File(pickedFile.path);
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileName = basename(_imageFile!.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = ref.putFile(
        _imageFile!,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _error = 'Failed to upload image: ${e.toString()}';
      });
      return null;
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final imageUrl = await _uploadImage();
      if (_imageFile != null && imageUrl == null) return;

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'category': _category,
        'imageUrl': imageUrl,
        'sellerId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'approved': false,
        'rating': 0,
        'reviewCount': 0,
        'searchKeywords': _generateSearchKeywords(_nameController.text),
      };

      await FirebaseFirestore.instance.collection('products').add(productData);

      if (!mounted) return;

      _formKey.currentState?.reset();
      setState(() {
        _imageFile = null;
        _uploadProgress = 0;
      });

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Product submitted for approval!'),
          duration: Duration(seconds: 3),
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context as BuildContext).pop();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Submission failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _generateSearchKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().split(' ');

    for (int i = 0; i < words.length; i++) {
      for (int j = 1; j <= words.length - i; j++) {
        keywords.add(words.sublist(i, i + j).join(' '));
      }
    }

    return keywords.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(
                children: [
                if (_error != null)
            Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      ),

      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: _imageFile != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_a_photo, size: 50),
              SizedBox(height: 8),
              Text('Tap to add product image'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),

      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Product Name*',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter product name';
          }
          if (value.trim().length < 3) {
            return 'Name too short (min 3 chars)';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _descController,
        decoration: const InputDecoration(
          labelText: 'Description*',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter description';
          }
          if (value.trim().length < 10) {
            return 'Description too short (min 10 chars)';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price*',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Enter valid price';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stock';
                }
                final stock = int.tryParse(value);
                if (stock == null || stock < 0) {
                  return 'Enter valid number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      DropdownButtonFormField(
        value: _category,
        decoration: const InputDecoration(
          labelText: 'Category*',
          border: OutlineInputBorder(),
        ),
        items: _categories
            .map((cat) => DropdownMenuItem(
          value: cat,
          child: Text(cat),
        ))
            .toList(),
        onChanged: (value) => setState(() => _category = value!),
        validator: (value) =>
        value == null ? 'Please select category' : null,
      ),
      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isLoading ? null : _submitProduct,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Submit Product',
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