// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:share_plus/share_plus.dart';

import 'create_post_dialog.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  String _selectedLanguage = 'en';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showCreatePostDialog(context),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Search
          SliverAppBar(
            title: Text(translate('forum.title')),
            backgroundColor: Colors.green,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _showSearchDialog,
              ),
              _buildLanguageDropdown(),
            ],
          ),

          // Problem Reporting Section
          SliverToBoxAdapter(
            child: _buildProblemBanner(),
          ),

          // Posts Section
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          translate('forum.no_posts'),
                          style: TextStyle(color: Colors.grey[600]),

                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showCreatePostDialog(context),
                          child: Text(translate('forum.create_first_post')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    var post = snapshot.data!.docs[index];
                    return _buildPostCard(post);
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(QueryDocumentSnapshot post) {
    final timestamp = (post['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, h:mm a').format(timestamp);
    final likesCount = (post['likes'] as List? ?? []).length;
    final commentsCount = post['commentsCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPostDetails(post),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      post['authorName']?.substring(0, 1) ?? 'A',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['authorName'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_auth.currentUser?.uid == post['authorId'])
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onPressed: () => _showPostOptions(post),

                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Post Content
              Text(
                post['content'],
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),

              // Post Image (if exists)
              if (post['imageUrl'] != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post['imageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              // Post Actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Likes
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: (post['likes'] ?? []).contains(_auth.currentUser?.uid)
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                        onPressed: () => _likePost(post.id),
                      ),
                      Text(likesCount.toString()),
                    ],
                  ),

                  // Comments
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.comment, color: Colors.grey[600]),
                        onPressed: () => _showPostDetails(post),
                      ),
                      Text(commentsCount.toString()),
                    ],
                  ),

                  // Share
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.grey[600]),
                    onPressed: () => _sharePost(post),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemBanner() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.green[800]),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  translate('forum.problem_banner.title'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            translate('forum.problem_banner.description'),
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  label: Text(_isListening
                      ? translate('forum.listening')
                      : translate('forum.speak')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _toggleListening,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(translate('forum.type')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _showCreatePostDialog(context),
                ),
              ),
            ],
          ),
          if (_isListening || _spokenText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_spokenText)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: _changeLanguage,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              const Icon(Icons.language, color: Colors.grey),
              const SizedBox(width: 8),
              Text(translate('language.english')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sw',
          child: Row(
            children: [
              const Icon(Icons.language, color: Colors.grey),
              const SizedBox(width: 8),
              Text(translate('language.swahili')),
            ],
          ),
        ),
      ],
    );
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

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreatePostDialog(
          initialText: _spokenText,
          selectedLanguage: _selectedLanguage,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() => _spokenText = '');
      if (_isListening) await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _showPostDetails(QueryDocumentSnapshot post) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PostDetailsDialog(post: post),
    );
  }

  Future<void> _showPostOptions(QueryDocumentSnapshot post) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => PostOptionsDialog(post: post),
    );
  }

  Future<void> _showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('forum.search')),
        content: TextField(
          decoration: InputDecoration(
            hintText: translate('forum.search_hint'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(translate('search')),
          ),
        ],
      ),
    );
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

  Future<void> _sharePost(QueryDocumentSnapshot post) async {
    await Share.share(
      '${post['title']}\n\n${post['content']}\n\nShared from Africulture App',
      subject: 'Check out this farming post',
    );
  }
}

// Additional dialog widgets would be defined here...