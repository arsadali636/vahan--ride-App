import 'package:equatable/equatable.dart';

import 'comment_reply.dart';

/// Domain entity for a comment with replies.
class Comment extends Equatable {
  final String id;
  final String author;
  final String initials;
  final String color;
  final String? photo;
  final String content;
  final String createdAt;
  final bool isMine;
  final List<CommentReply> replies;

  const Comment({
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
