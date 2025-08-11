import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/firebase_service.dart';

class ContentProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Content> _contents = [];
  bool _isLoading = false;

  List<Content> get contents => _contents;
  bool get isLoading => _isLoading;

  Future<void> loadContents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firebaseService.getContent();

      _contents = data.map<Content>((json) {
        return Content.fromMap(json, json['id']);
      }).toList();

    } catch (e) {
      debugPrint('Error loading content: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  void approveContent(Content content) {
    final updated = content.copyWith(status: ContentStatus.published);
    _contents = _contents.map((c) => c.id == content.id ? updated : c).toList();
    notifyListeners();
  }

  void rejectContent(Content content) {
    final updated = content.copyWith(status: ContentStatus.rejected);
    _contents = _contents.map((c) => c.id == content.id ? updated : c).toList();
    notifyListeners();
  }
}
