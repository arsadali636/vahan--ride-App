import 'package:equatable/equatable.dart';

import '../../domain/entities/comment.dart';
import 'comment_reply_model.dart';

/// Wire-format model for a single comment (used in get comments response).
class CommentModel extends Equatable {
  final String id;
  final String author;
  final String initials;
  final String color;
  final String? photo;
  final String content;
  final String createdAt;
  final bool isMine;
  final List<CommentReplyModel> replies;

  const CommentModel({
    required this.id,
    required this.author,
    required this.initials,
    required this.color,
    this.photo,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      color: json['color'] as String? ?? '',
      photo: json['photo'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
      replies: (json['replies'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => CommentReplyModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
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
      isMine: isMine,
      replies: replies.map((e) => e.toEntity()).toList(),
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
    isMine,
    replies,
  ];
}
