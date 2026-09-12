import 'package:equatable/equatable.dart';

import '../../domain/entities/comment.dart';

/// Response model for POST /api/v1/feed/posts/{id}/comments/.
class PostCommentResponseModel extends Equatable {
  final String id;
  final String author;
  final String initials;
  final String color;
  final String? photo;
  final String content;
  final String createdAt;
  final int count;

  const PostCommentResponseModel({
    required this.id,
    required this.author,
    required this.initials,
    required this.color,
    this.photo,
    required this.content,
    required this.createdAt,
    required this.count,
  });

  factory PostCommentResponseModel.fromJson(Map<String, dynamic> json) {
    return PostCommentResponseModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      color: json['color'] as String? ?? '',
      photo: json['photo'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      count: json['comment_count'] as int? ?? 0,
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      author: author,
      initials: initials,
      color: color,
      photo: photo,
      content: content,
      createdAt: createdAt,
      isMine: true,
      replies: const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        initials,
        color,
        photo,
        content,
        createdAt,
        count,
      ];
}
