import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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
  bool _isPosting = false;
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
                onPressed: _isPosting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isPosting
                    ? SizedBox(
                        height: 40,
                        width: 40,
                        child: Lottie.asset(
                          'assets/animations/plant_grow.json',
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      )
                    : Text(translate('forum.post')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
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
    final user = _auth.currentUser;
    if (user == null) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final firstName = userDoc.data()?['firstName'] ?? '';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final authorName = (firstName + ' ' + lastName).trim().isEmpty
          ? 'Anonymous Farmer'
          : (firstName + ' ' + lastName).trim();

      String? imageUrl;
      if (_imagePath != null) {
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
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'content': content,
        'imageUrl': imageUrl,
        'authorId': user.uid,
        'authorName': authorName,
        'timestamp': Timestamp.now(),
        'likes': [],
        'commentsCount': 0,
        'language': widget.selectedLanguage,
      });

      Navigator.pop(context, {'success': true});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    } finally {
      setState(() => _isPosting = false);
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

  Future<void> _deleteComment(String commentId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final commentRef = _firestore
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .doc(commentId);

    try {
      final commentSnap = await commentRef.get();

      if (!commentSnap.exists) return;

      if (commentSnap['authorId'] != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can't delete this comment.")),
        );
        return;
      }

      await commentRef.delete();

      await _firestore.collection('posts').doc(widget.post.id).update({
        'commentsCount': FieldValue.increment(-1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment deleted successfully.")),
      );
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete comment.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
    final currentUserId = _auth.currentUser?.uid;

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
          if (comment['authorId'] == currentUserId)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deleteComment(comment.id),
            ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final firstName = userDoc.data()?['firstName'] ?? '';
    final lastName = userDoc.data()?['lastName'] ?? '';
    final authorName = (firstName + ' ' + lastName).trim().isEmpty
        ? 'Anonymous Farmer'
        : (firstName + ' ' + lastName).trim();

    try {
      await _firestore
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'content': content,
            'authorId': user.uid,
            'authorName': authorName,
            'timestamp': Timestamp.now(),
          });

      await _firestore.collection('posts').doc(widget.post.id).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      debugPrint('Commenting error is: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(translate('forum.comment_error'))));
    }
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
            title: Text(
              translate('forum.delete_post'),
              style: const TextStyle(color: Colors.red),
            ),
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
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

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
