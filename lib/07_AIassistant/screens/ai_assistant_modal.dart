import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/gemini_service.dart';
import '../services/image_upload_service.dart';
import '../services/image_upload_service.dart' as ImageUploadService;
import '../widgets/chat_message.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void handleUploadedImage(String imageUrl) {
    setState(() {
      messages.add(ChatMessage(imageUrl: imageUrl, isUser: true));
      isLoading = true;
    });

    GeminiService.sendImageWithPrompt(imageUrl, "Diagnose this plant").then((response) {
      setState(() {
        messages.add(ChatMessage(text: response, isUser: false));
        isLoading = false;
      });
      _flutterTts.speak(response);
    }).catchError((e) {
      setState(() {
        messages.add(ChatMessage(text: 'Error: \$e', isUser: false));
        isLoading = false;
      });
    });

    _scrollToBottom();
  }

  void sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: input, isUser: true));
      isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final reply = await GeminiService.getGeminiResponse(input);
      setState(() {
        messages.add(ChatMessage(text: reply, isUser: false));
        isLoading = false;
      });
      _flutterTts.speak(reply);
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(text: 'Error: \$e', isUser: false));
        isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> deleteImageFromFirebase(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint("Delete failed: \$e");
    }
  }

  void _confirmDelete(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Image"),
        content: Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await deleteImageFromFirebase(imageUrl);
              setState(() {
                messages.removeWhere((msg) => msg.imageUrl == imageUrl);
              });
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      } else {
        print("Speech recognition not available");
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }


  Widget _buildPromptChip(String label) {
    return GestureDetector(
      onTap: () => sendMessage(label),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7EC),
      appBar: AppBar(
        title: const Text("AfriBot"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              children: [
                _buildPromptChip('Diagnose crop problem'),
                _buildPromptChip('Best fertilizers to use'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (_, index) {
                if (index < messages.length) {
                  final msg = messages[index];
                  return GestureDetector(
                    onLongPress: msg.imageUrl != null ? () => _confirmDelete(msg.imageUrl!) : null,
                    child: msg,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Lottie.asset('assets/animations/typing.json'),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Take Photo"),
                              onTap: () async {
                                Navigator.pop(context);
                                setState(() => isUploadingImage = true);
                                final imageUrl = await pickAndUploadImage(source: ImageSource.camera);
                                setState(() => isUploadingImage = false);
                                if (imageUrl != null) handleUploadedImage(imageUrl);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text("Choose from Gallery"),
                              onTap: () async {
                                Navigator.pop(context);
                                setState(() => isUploadingImage = true);
                                final imageUrl = await pickAndUploadImage(source: ImageSource.gallery);
                                setState(() => isUploadingImage = false);
                                if (imageUrl != null) handleUploadedImage(imageUrl);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'How can I help you today?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _listen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
