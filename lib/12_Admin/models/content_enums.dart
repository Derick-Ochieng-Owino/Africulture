import 'package:flutter/material.dart';

enum ContentType { post, video, image, article }

extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.post:
        return 'Post';
      case ContentType.video:
        return 'Video';
      case ContentType.image:
        return 'Image';
      case ContentType.article:
        return 'Article';
    }
  }
}

enum ContentStatus { draft, published, rejected }

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
