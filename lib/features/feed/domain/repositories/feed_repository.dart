import 'dart:io';

import '../entities/comment.dart';
import '../entities/comment_reply.dart';
import '../entities/feed_post.dart';

/// Repository for the professional feed.
abstract class FeedRepository {
  /// Fetches a page of feed posts.
  Future<List<FeedPost>> getFeedPosts({
    required int page,
    required int pageSize,
  });

  /// Whether there are more pages available.
  bool get hasMore;

  /// Creates a new feed post with optional image.
  Future<void> createPost({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
    List<int>? imageBytes,
    String? imageName,
  });

  /// Toggles like on a post. Returns the server-confirmed `{liked, count}`.
  Future<({bool liked, int count})> likePost({required String postId});

  /// Edits an existing post.
  Future<({bool success, String content, String? image})> editPost({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  });

  /// Deletes a post.
  Future<bool> deletePost({required String postId});

  /// Fetches comments for a post.
  Future<List<Comment>> getComments({required String postId});

  /// Posts a new comment on a post.
  Future<Comment> postComment({
    required String postId,
    required String content,
  });

  /// Replies to a comment.
  Future<CommentReply> replyComment({
    required String commentId,
    required String content,
  });

  /// Edits an existing comment.
  Future<({bool success, String content})> editComment({
    required String commentId,
    required String content,
  });

  /// Deletes a comment.
  Future<bool> deleteComment({required String commentId});
}
