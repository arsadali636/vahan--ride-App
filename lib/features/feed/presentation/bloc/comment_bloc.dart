// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/comment_reply.dart';
import '../../domain/usecases/post_management_usecases.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required GetComments getComments,
    required PostComment postComment,
    required ReplyComment replyComment,
    required EditComment editComment,
    required DeleteComment deleteComment,
  })  : _getComments = getComments,
        _postComment = postComment,
        _replyComment = replyComment,
        _editComment = editComment,
        _deleteComment = deleteComment,
        super(const CommentState()) {
    on<CommentStarted>(_onStarted);
    on<CommentSubmitted>(_onSubmitted);
    on<CommentReplySubmitted>(_onReplySubmitted);
    on<CommentEdited>(_onEdited);
    on<CommentDeleted>(_onDeleted);
    on<CommentReplyEdited>(_onReplyEdited);
    on<CommentReplyDeleted>(_onReplyDeleted);
    on<CommentClearedError>(_onCommentClearedError);
  }

  final GetComments _getComments;
  final PostComment _postComment;
  final ReplyComment _replyComment;
  final EditComment _editComment;
  final DeleteComment _deleteComment;

  Future<void> _onStarted(
    CommentStarted event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(
      status: CommentStatus.loading,
      clearError: true,
    ));
    try {
      final comments = await _getComments(postId: event.postId);
      emit(state.copyWith(
        status: CommentStatus.loaded,
        comments: comments,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onSubmitted(
    CommentSubmitted event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.submitting));
    try {
      final newComment = await _postComment(
        postId: event.postId,
        content: event.content,
      );
      final updated = [...state.comments, newComment];
      emit(state.copyWith(
        status: CommentStatus.loaded,
        comments: updated,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onReplySubmitted(
    CommentReplySubmitted event,
    Emitter<CommentState> emit,
  ) async {
    emit(state.copyWith(status: CommentStatus.submitting));
    try {
      final reply = await _replyComment(
        commentId: event.commentId,
        content: event.content,
      );
      final updated = state.comments.map((comment) {
        if (comment.id != event.commentId) return comment;
        return Comment(
          id: comment.id,
          author: comment.author,
          initials: comment.initials,
          color: comment.color,
          photo: comment.photo,
          content: comment.content,
          createdAt: comment.createdAt,
          isMine: comment.isMine,
          replies: [...comment.replies, reply],
        );
      }).toList();
      emit(state.copyWith(
        status: CommentStatus.loaded,
        comments: updated,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onEdited(
    CommentEdited event,
    Emitter<CommentState> emit,
  ) async {
    final updated = state.comments.map((comment) {
      if (comment.id != event.commentId) return comment;
      return Comment(
        id: comment.id,
        author: comment.author,
        initials: comment.initials,
        color: comment.color,
        photo: comment.photo,
        content: event.content,
        createdAt: comment.createdAt,
        isMine: comment.isMine,
        replies: comment.replies,
      );
    }).toList();
    emit(state.copyWith(comments: updated));

    try {
      await _editComment(
        commentId: event.commentId,
        content: event.content,
      );
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onDeleted(
    CommentDeleted event,
    Emitter<CommentState> emit,
  ) async {
    final removed = state.comments
        .where((c) => c.id != event.commentId)
        .toList();
    emit(state.copyWith(comments: removed));

    try {
      await _deleteComment(commentId: event.commentId);
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onReplyEdited(
    CommentReplyEdited event,
    Emitter<CommentState> emit,
  ) async {
    final updated = state.comments.map((comment) {
      final updatedReplies = comment.replies.map((reply) {
        if (reply.id != event.replyId) return reply;
        return CommentReply(
          id: reply.id,
          author: reply.author,
          initials: reply.initials,
          color: reply.color,
          photo: reply.photo,
          content: event.content,
          createdAt: reply.createdAt,
          isMine: reply.isMine,
        );
      }).toList();
      return Comment(
        id: comment.id,
        author: comment.author,
        initials: comment.initials,
        color: comment.color,
        photo: comment.photo,
        content: comment.content,
        createdAt: comment.createdAt,
        isMine: comment.isMine,
        replies: updatedReplies,
      );
    }).toList();
    emit(state.copyWith(comments: updated));
  }

  Future<void> _onReplyDeleted(
    CommentReplyDeleted event,
    Emitter<CommentState> emit,
  ) async {
    final updated = state.comments.map((comment) {
      if (comment.id != event.commentId) return comment;
      return Comment(
        id: comment.id,
        author: comment.author,
        initials: comment.initials,
        color: comment.color,
        photo: comment.photo,
        content: comment.content,
        createdAt: comment.createdAt,
        isMine: comment.isMine,
        replies: comment.replies
            .where((r) => r.id != event.replyId)
            .toList(),
      );
    }).toList();
    emit(state.copyWith(comments: updated));
  }

  void _onCommentClearedError(
    CommentClearedError event,
    Emitter<CommentState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
