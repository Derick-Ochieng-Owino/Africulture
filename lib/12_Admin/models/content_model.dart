import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ContentType { article, video, image }
enum ContentStatus { draft, published, rejected }

extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.article:
        return 'Article';
      case ContentType.video:
        return 'Video';
      case ContentType.image:
        return 'Image';
    }
  }
}

extension ContentStatusExtension on ContentStatus {
  String get displayName {
    switch (this) {
      case ContentStatus.draft:
        return 'Draft';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ContentStatus.draft:
        return Colors.grey;
      case ContentStatus.published:
        return Colors.green;
      case ContentStatus.rejected:
        return Colors.red;
    }
  }
}

class Content {
  final String id;
  final String authorId;
  final String authorName;
  final int commentsCount;
  final String content;
  final String description;
  final String imageUrl;
  final String language;
  final List<String> likes;
  final Timestamp timestamp;
  final String title;
  final ContentType type;
  final ContentStatus status;
  final List<String> tags;

  Content({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.commentsCount,
    required this.content,
    required this.description,
    required this.imageUrl,
    required this.language,
    required this.likes,
    required this.timestamp,
    required this.title,
    required this.type,
    required this.status,
    required this.tags,
  });

  factory Content.fromMap(Map<String, dynamic> map, String docId) {
    return Content(
      id: docId,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      commentsCount: (map['commentsCount'] ?? 0) as int,
      content: map['content'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      language: map['language'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      timestamp: map['timestamp'] ?? Timestamp.now(),
      title: map['title'] ?? '',
      type: ContentType.values.firstWhere(
            (e) => e.toString().split('.').last == (map['type'] ?? 'article'),
        orElse: () => ContentType.article,
      ),
      status: ContentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (map['status'] ?? 'draft'),
        orElse: () => ContentStatus.draft,
      ),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'commentsCount': commentsCount,
      'content': content,
      'description': description,
      'imageUrl': imageUrl,
      'language': language,
      'likes': likes,
      'timestamp': timestamp,
      'title': title,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'tags': tags,
    };
  }

  Content copyWith({
    String? id,
    String? authorId,
    String? authorName,
    int? commentsCount,
    String? content,
    String? description,
    String? imageUrl,
    String? language,
    List<String>? likes,
    Timestamp? timestamp,
    String? title,
    ContentType? type,
    ContentStatus? status,
    List<String>? tags,
  }) {
    return Content(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      commentsCount: commentsCount ?? this.commentsCount,
      content: content ?? this.content,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      language: language ?? this.language,
      likes: likes ?? this.likes,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }
}
