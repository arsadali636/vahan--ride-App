import 'package:equatable/equatable.dart';

/// Domain entity for a reply to a comment.
class CommentReply extends Equatable {
  final String id;
  final String author;
  final String initials;
  final String color;
  final String? photo;
  final String content;
  final String createdAt;
  final bool isMine;

  const CommentReply({
    required this.id,
    required this.author,
    required this.initials,
    required this.color,
    this.photo,
    required this.content,
    required this.createdAt,
    required this.isMine,
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
      ];
}
