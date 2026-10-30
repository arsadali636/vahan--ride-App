import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_reply.dart';

/// Response model for POST /api/v1/feed/comments/{id}/reply/.
class ReplyCommentResponseModel extends Equatable {
  final String id;
  final String author;
  final String initials;
  final String color;
  final String? photo;
  final String content;
  final String createdAt;
  final bool isMine;

  const ReplyCommentResponseModel({
    required this.id,
    required this.author,
    required this.initials,
    required this.color,
    this.photo,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  factory ReplyCommentResponseModel.fromJson(Map<String, dynamic> json) {
    return ReplyCommentResponseModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      color: json['color'] as String? ?? '',
      photo: json['photo'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
    );
  }

  CommentReply toEntity() {
    return CommentReply(
      id: id,
      author: author,
      initials: initials,
      color: color,
      photo: photo,
      content: content,
      createdAt: createdAt,
      isMine: isMine,
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
  ];
}
