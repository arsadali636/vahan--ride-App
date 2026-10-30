import 'package:equatable/equatable.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class CommentStarted extends CommentEvent {
  final String postId;
  const CommentStarted({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class CommentSubmitted extends CommentEvent {
  final String postId;
  final String content;
  const CommentSubmitted({required this.postId, required this.content});

  @override
  List<Object?> get props => [postId, content];
}

class CommentReplySubmitted extends CommentEvent {
  final String commentId;
  final String content;
  const CommentReplySubmitted({required this.commentId, required this.content});

  @override
  List<Object?> get props => [commentId, content];
}

class CommentEdited extends CommentEvent {
  final String commentId;
  final String content;
  const CommentEdited({required this.commentId, required this.content});

  @override
  List<Object?> get props => [commentId, content];
}

class CommentDeleted extends CommentEvent {
  final String commentId;
  const CommentDeleted({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CommentReplyEdited extends CommentEvent {
  final String replyId;
  final String content;
  const CommentReplyEdited({required this.replyId, required this.content});

  @override
  List<Object?> get props => [replyId, content];
}

class CommentReplyDeleted extends CommentEvent {
  final String replyId;
  final String commentId;
  const CommentReplyDeleted({required this.replyId, required this.commentId});

  @override
  List<Object?> get props => [replyId, commentId];
}

class CommentClearedError extends CommentEvent {
  const CommentClearedError();
}
