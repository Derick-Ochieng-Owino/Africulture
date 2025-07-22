// ✅ 1. Product Add Form Page (product_add_page.dart)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', description = '', category = 'Seeds';
  double price = 0.0;
  File? imageFile;

  final picker = ImagePicker();
  final categories = ['Seeds', 'Fertilizer', 'Tools', 'Machinery', 'Pesticides'];

  Future<String> uploadImage(File image) async {
    final ref = FirebaseStorage.instance.ref().child('product_images/${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> submitProduct() async {
    if (_formKey.currentState!.validate() && imageFile != null) {
      _formKey.currentState!.save();

      final imageUrl = await uploadImage(imageFile!);

      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'approved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product submitted for approval!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (val) => description = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (val) => price = double.tryParse(val!) ?? 0,
              ),
              DropdownButtonFormField(
                value: category,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              const SizedBox(height: 16),
              imageFile != null
                  ? Image.file(imageFile!, height: 150)
                  : TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitProduct,
                child: const Text('Submit Product'),
              )
            ],
          ),
        ),
      ),
    );
  }
}