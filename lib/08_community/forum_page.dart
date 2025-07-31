import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:share_plus/share_plus.dart';
import 'create_post_dialog.dart';
import 'delete_post_button.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _spokenText = '');
      await _speech.listen(
        onResult: (result) => setState(() => _spokenText = result.recognizedWords),
        localeId: _selectedLanguage,
      );
      setState(() => _isListening = true);
    }
  }

  Future<void> _changeLanguage(String language) async {
    setState(() => _selectedLanguage = language);
    await changeLocale(context, language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('forum.title')),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(context),
          ),
          _buildLanguageDropdown(),
        ],
      ),
      body: Column(
        children: [
          // Problem Reporting Banner
          _buildProblemBanner(),

          // Posts Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post header with delete button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  post['authorName'] ?? 'Anonymous',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (_auth.currentUser?.uid == post['authorId'])
                                  DeletePostButton(
                                    postId: post.id,
                                    authorId: post['authorId'],
                                    onDeleted: () {
                                      // Optional: Show confirmation or update UI
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Post deleted')),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(post['content']),
                            const SizedBox(height: 12),
                            // Existing like/comment/share buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: (post['likes'] ?? []).contains(_auth.currentUser?.uid)
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _likePost(post.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () => _showCommentsDialog(post.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () => _sharePost(post),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('forum.problem_banner.title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: Text(_isListening ? translate('forum.listening') : translate('forum.speak')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleListening,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.keyboard),
                  label: Text(translate('forum.type')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue!),
                  ),
                  onPressed: () => _showCreatePostDialog(context),
                ),
              ),
            ],
          ),
          if (_isListening || _spokenText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_spokenText),
          ],
          const SizedBox(height: 8),
          Text(
            translate('forum.language_support'),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: _changeLanguage,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'en', child: Text(translate('language.english'))),
        PopupMenuItem(value: 'sw', child: Text(translate('language.swahili'))),
        // Add more languages as needed
      ],
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        initialText: _spokenText,
        selectedLanguage: _selectedLanguage,
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() => _spokenText = '');
      if (_isListening) await _speech.stop();
      setState(() => _isListening = false);
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

  Future<void> _showCommentsDialog(String postId) async {
    final comments = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .get();

    showDialog(
      context: context,
      builder: (context) => CommentsDialog(
        postId: postId,
        initialComments: comments.docs,
      ),
    );
  }

  Future<void> _sharePost(QueryDocumentSnapshot post) async {
    await Share.share(
      '${post['title']}\n\n${post['content']}\n\nShared from Africulture App',
      subject: 'Check out this farming post',
    );
  }
}

class CommentsDialog extends StatefulWidget {
  final String postId;
  final List<QueryDocumentSnapshot> initialComments;

  const CommentsDialog({
    super.key,
    required this.postId,
    required this.initialComments,
  });

  @override
  State<CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();
  late Stream<QuerySnapshot> _commentsStream;

  @override
  void initState() {
    super.initState();
    _commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translate('forum.comments'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Comments List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _commentsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment['content']),
                        subtitle: Text(
                          '${comment['authorName']} • ${DateFormat('MMM d, h:mm a').format((comment['timestamp'] as Timestamp).toDate())}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add Comment
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: translate('forum.add_comment'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Add comment
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'content': _commentController.text,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'timestamp': Timestamp.now(),
      });

      // Update comments count
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}