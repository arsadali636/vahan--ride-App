import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';

enum CommentStatus { initial, loading, loaded, submitting, failure }

class CommentState extends Equatable {
  final CommentStatus status;
  final List<Comment> comments;
  final Failure? error;
  final String? parentIdToDelete;

  const CommentState({
    this.status = CommentStatus.initial,
    this.comments = const [],
    this.error,
    this.parentIdToDelete,
  });

  CommentState copyWith({
    CommentStatus? status,
    List<Comment>? comments,
    Failure? error,
    String? parentIdToDelete,
    bool clearError = false,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      error: clearError ? null : (error ?? this.error),
      parentIdToDelete:
          clearError ? null : (parentIdToDelete ?? this.parentIdToDelete),
    );
  }

  @override
  List<Object?> get props => [status, comments, error, parentIdToDelete];
}
