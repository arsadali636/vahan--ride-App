import 'dart:io';

import '../entities/comment.dart';
import '../entities/comment_reply.dart';
import '../repositories/feed_repository.dart';

/// Edits an existing post.
class EditPost {
  EditPost(this._repository);

  final FeedRepository _repository;

  Future<({bool success, String content, String? image})> call({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  }) {
    return _repository.editPost(
      postId: postId,
      content: content,
      removeImage: removeImage,
      imageFile: imageFile,
    );
  }
}

/// Deletes a post.
class DeletePost {
  DeletePost(this._repository);

  final FeedRepository _repository;

  Future<bool> call({required String postId}) {
    return _repository.deletePost(postId: postId);
  }
}

/// Fetches comments for a post.
class GetComments {
  GetComments(this._repository);

  final FeedRepository _repository;

  Future<List<Comment>> call({required String postId}) {
    return _repository.getComments(postId: postId);
  }
}

/// Posts a new comment on a post.
class PostComment {
  PostComment(this._repository);

  final FeedRepository _repository;

  Future<Comment> call({required String postId, required String content}) {
    return _repository.postComment(postId: postId, content: content);
  }
}

/// Replies to a comment.
class ReplyComment {
  ReplyComment(this._repository);

  final FeedRepository _repository;

  Future<CommentReply> call({
    required String commentId,
    required String content,
  }) {
    return _repository.replyComment(commentId: commentId, content: content);
  }
}

/// Edits an existing comment.
class EditComment {
  EditComment(this._repository);

  final FeedRepository _repository;

  Future<({bool success, String content})> call({
    required String commentId,
    required String content,
  }) {
    return _repository.editComment(commentId: commentId, content: content);
  }
}

/// Deletes a comment.
class DeleteComment {
  DeleteComment(this._repository);

  final FeedRepository _repository;

  Future<bool> call({required String commentId}) {
    return _repository.deleteComment(commentId: commentId);
  }
}
