import 'dart:convert';
import 'package:africulture/11_home/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<DocumentSnapshot> _posts = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _posts = snapshot.docs;
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> cachePosts(List<QueryDocumentSnapshot> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> postList = posts.map((p) => p.data() as Map<String, dynamic>).toList();
    prefs.setString('cached_posts', jsonEncode(postList));
  }

  Future<List<Map<String, dynamic>>> loadCachedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_posts');
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }
    return [];
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
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showCreatePostDialog(context),
      ),
      body: _isLoading
      ?const Center(child: PlantGrowLoading(message: "Loading...",))
      : RefreshIndicator(
        onRefresh: _loadPosts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              title: Text(translate('forum.title')),
              backgroundColor: Colors.teal,
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
      ),
    );
  }

  Widget _buildPostCard(QueryDocumentSnapshot post) {
    final timestamp = (post['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, h:mm a').format(timestamp);
    final likesCount = (post['likes'] as List? ?? []).length;
    final commentsCount = post['commentsCount'] ?? 0;
    String authorName = (post['authorName'] ?? '').toString().trim();
    String initial = authorName.isNotEmpty ? authorName.substring(0, 1) : 'A';

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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (post['authorName']?.trim().isEmpty ?? true)
                              ? 'Anonymous'
                              : post['authorName'],
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

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        icon: Icon(Icons.comment, color: Colors.blue[200]),
                        onPressed: () => _showPostDetails(post),
                      ),
                      Text(commentsCount.toString()),
                    ],
                  ),

                  // Share
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.teal[300]),
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
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.teal[800]),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  translate('forum.problem_banner.title'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
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
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal),
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
                    backgroundColor: Colors.teal,
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
                  Icon(Icons.mic, color: Colors.teal),
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

  //Search options function
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


  //Like post function
  Future<void> _likePost(String postId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Get current user details
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final firstName = userDoc['firstName'] ?? 'Someone';

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final post = await transaction.get(postRef);
      if (!post.exists) return;

      final likes = List<String>.from(post['likes'] ?? []);
      final authorId = post['authorId'] as String?;
      bool isLiking = false;

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
        isLiking = true;
      }

      transaction.update(postRef, {'likes': likes});

      if (isLiking && authorId != null && authorId != userId) {
        try {
          final existing = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: authorId)
              .where('postId', isEqualTo: postId)
              .where('fromUserId', isEqualTo: userId)
              .where('type', isEqualTo: 'like')
              .get();

          if (existing.docs.isEmpty) {
            await _firestore.collection('notifications').add({
              'userId': authorId,
              'fromUserId': userId,
              'fromUserName': firstName,
              'postId': postId,
              'type': 'like',
              'message': '$firstName liked your post.',
              'timestamp': FieldValue.serverTimestamp(),
              'read': false,
            });
          }
        } catch (e) {
          debugPrint('Notification not sent: $e');
        }
      }
    });
  }


  //Share post function
  Future<void> _sharePost(QueryDocumentSnapshot post) async {
    try {
      final String title = "Africulture";//post['title'] ?? '';
      final String content = post['content'] ?? '';
      final String? imageUrl = post['imageUrl'];

      String shareText = "$title\n\n$content";

      if (imageUrl != null && imageUrl.isNotEmpty) {
        shareText += "\n\nImage: $imageUrl";
      }

      await Share.share(shareText, subject: title.isNotEmpty ? title : "Check this out!");
    } catch (e) {
      print("Error sharing post: $e");
    }
  }
}