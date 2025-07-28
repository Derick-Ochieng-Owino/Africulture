import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostDialog extends StatefulWidget {
  final String initialText;
  final String selectedLanguage;

  const CreatePostDialog({
    super.key,
    this.initialText = '',
    required this.selectedLanguage,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialText;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  translate('forum.create_post'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
            
                // Image Upload
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imageFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo, size: 40),
                        Text(translate('forum.add_image')),
                      ],
                    )
                        : Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
            
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: translate('forum.title_optional'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
            
                // Content Field
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: translate('forum.share_prompt'),
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translate('forum.content_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                // Post Button
                SizedBox(
                  width: double.infinity,
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      translate('forum.post'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload image if selected
      String? imageUrl;

      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images/${DateTime.now().millisecondsSinceEpoch}');

        UploadTask uploadTask;

        if (kIsWeb) {
          // _imageFile should be Uint8List on web
          uploadTask = ref.putData(_imageFile as Uint8List);
        } else {
          // _imageFile should be File on mobile
          uploadTask = ref.putFile(_imageFile as io.File);
        }

        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Create post document
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'imageUrl': imageUrl,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous Farmer',
        'timestamp': Timestamp.now(),
        'likes': [],
        'commentsCount': 0,
        'language': widget.selectedLanguage,
      });

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}