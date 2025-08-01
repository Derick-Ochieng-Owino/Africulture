// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

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
  final TextEditingController _contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _imagePath;
  bool _isUploading = false;
  Uint8List? _webImageData;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.initialText;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('forum.create_post'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: translate('forum.post_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_imagePath != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(_imagePath!)),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _imagePath = null),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _pickImage,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translate('cancel')),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitPost,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : Text(translate('forum.post')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });

      if (kIsWeb) {
        _webImageData = await pickedFile.readAsBytes();
      }
    }
  }


  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    debugPrint("Submit post called. Content: $content");

    if (content.isEmpty) {
      debugPrint("Post content is empty, aborting.");
      return;
    }

    setState(() => _isUploading = true);

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("User is null, aborting.");
      return;
    }

    try {
      String? imageUrl;
      if (_imagePath != null) {
        debugPrint("Uploading image...");
        final ref = _storage.ref().child(
          'post_images/${DateTime.now().millisecondsSinceEpoch}',
        );

        UploadTask uploadTask;

        if (kIsWeb) {
          if (_webImageData == null) throw Exception('Web image data is null');
          uploadTask = ref.putData(_webImageData!);
        } else {
          uploadTask = ref.putFile(File(_imagePath!));
        }

        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        debugPrint("Image uploaded: $imageUrl");
      }

      debugPrint("Creating post in Firestore...");
      await FirebaseFirestore.instance.collection('posts').add({
        'content': content, // ← use trimmed content
        'imageUrl': imageUrl,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous Farmer',
        'timestamp': Timestamp.now(),
        'likes': [],
        'commentsCount': 0,
        'language': widget.selectedLanguage,
      });

      debugPrint("Post successfully created");
      Navigator.pop(context, {'success': true});
    } catch (e) {
      debugPrint("Post creation failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }


  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

class PostDetailsDialog extends StatefulWidget {
  final QueryDocumentSnapshot post;

  const PostDetailsDialog({super.key, required this.post});

  @override
  State<PostDetailsDialog> createState() => _PostDetailsDialogState();
}

class _PostDetailsDialogState extends State<PostDetailsDialog> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = (widget.post['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, y • h:mm a').format(timestamp);
    final likesCount = (widget.post['likes'] as List? ?? []).length;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    widget.post['authorName']?.substring(0, 1) ?? 'A',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post['authorName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _sharePost(widget.post),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post['content'],
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Post Image (if exists)
          if (widget.post['imageUrl'] != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.post['imageUrl'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color:
                        (widget.post['likes'] ?? []).contains(
                          _auth.currentUser?.uid,
                        )
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                  onPressed: () => _likePost(widget.post.id),
                ),
                Text(likesCount.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.comment, color: Colors.grey),
                const SizedBox(width: 8),
                Text((widget.post['commentsCount'] ?? 0).toString()),
              ],
            ),
          ),
          const Divider(),

          // Comments Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(translate('forum.no_comments')));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data!.docs[index];
                    return _buildCommentItem(comment);
                  },
                );
              },
            ),
          ),

          // Add Comment
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: translate('forum.add_comment'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(QueryDocumentSnapshot comment) {
    final timestamp = (comment['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, h:mm a').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[100],
            child: Text(
              comment['authorName']?.substring(0, 1) ?? 'A',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['authorName'] ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(comment['content'], style: const TextStyle(fontSize: 14)),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePost(QueryDocumentSnapshot post) async {
    await Share.share(
      '${post['title']}\n\n${post['content']}\n\nShared from Africulture App',
      subject: 'Check out this farming post',
    );
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Add comment
      await _firestore
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'content': content,
            'authorId': user.uid,
            'authorName': user.displayName ?? 'Anonymous',
            'timestamp': Timestamp.now(),
          });

      // Update comments count
      await _firestore.collection('posts').doc(widget.post.id).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(translate('forum.comment_error'))));
    }
  }

  Future<void> _likePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final post = await transaction.get(postRef);
      if (!post.exists) return;

      final likes = List<String>.from(post['likes'] ?? []);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(postRef, {'likes': likes});
    });
  }
}

class PostOptionsDialog extends StatelessWidget {
  final QueryDocumentSnapshot post;

  const PostOptionsDialog({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(translate('forum.edit_post')),
            onTap: () {
              Navigator.pop(context);
              _showEditPostDialog(context, post);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(translate('forum.delete_post'),
              style: const TextStyle(color: Colors.red),),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, post.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(translate('cancel')),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, QueryDocumentSnapshot post) {
    final controller = TextEditingController(text: post['content']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translate('forum.edit_post'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: translate('forum.post_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(translate('cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _updatePost(post.id, controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: Text(translate('save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePost(String postId, String content) async {
    if (content.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'content': content,
      });
    } catch (e) {
      // Handle error
    }
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('forum.delete_post')),
        content: Text(translate('forum.delete_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              _deletePost(postId);
              Navigator.pop(context);
              Navigator.pop(context); // Close the options dialog too
            },
            child: Text(
              translate('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Delete the post
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // Optionally: Delete all comments associated with this post
      final comments = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Handle error
    }
  }
}
