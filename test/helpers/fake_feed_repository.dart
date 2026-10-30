import 'dart:io';

import 'package:doc_connect_app/features/feed/domain/entities/comment.dart';
import 'package:doc_connect_app/features/feed/domain/entities/comment_reply.dart';
import 'package:doc_connect_app/features/feed/domain/entities/feed_post.dart';
import 'package:doc_connect_app/features/feed/domain/repositories/feed_repository.dart';

class FakeFeedRepository implements FeedRepository {
  List<FeedPost> posts = [
    const FeedPost(
      id: 'post-1',
      author: 'Dr. Priya Sharma',
      authorId: 'doc-100',
      headline: 'Neurologist at Max Healthcare',
      initials: 'PS',
      color: '#378FE9',
      postType: 'update',
      postTypeDisplay: 'Update',
      content: 'Sharing our latest research findings in clinical neurology.',
      likeCount: 24,
      commentCount: 5,
      liked: false,
      isMine: false,
      piiFlagged: false,
      createdAt: '2026-03-30T09:00:00Z',
    ),
  ];

  int createPostCalls = 0;
  String? lastCreatedContent;
  String? lastCreatedPostType;
  bool? lastCreatedIsAnonymous;

  @override
  bool get hasMore => false;

  @override
  Future<List<FeedPost>> getFeedPosts({
    required int page,
    required int pageSize,
  }) async {
    return posts;
  }

  @override
  Future<void> createPost({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    createPostCalls++;
    lastCreatedContent = content;
    lastCreatedPostType = postType;
    lastCreatedIsAnonymous = isAnonymous;
  }

  @override
  Future<({bool liked, int count})> likePost({required String postId}) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final old = posts[index];
      final newLiked = !old.liked;
      final newCount = newLiked ? old.likeCount + 1 : old.likeCount - 1;
      posts[index] = old.copyWith(liked: newLiked, likeCount: newCount);
      return (liked: newLiked, count: newCount);
    }
    return (liked: true, count: 1);
  }

  @override
  Future<({bool success, String content, String? image})> editPost({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  }) async {
    return (success: true, content: content, image: null);
  }

  @override
  Future<bool> deletePost({required String postId}) async {
    posts.removeWhere((p) => p.id == postId);
    return true;
  }

  @override
  Future<List<Comment>> getComments({required String postId}) async {
    return const [];
  }

  @override
  Future<Comment> postComment({
    required String postId,
    required String content,
  }) async {
    return Comment(
      id: 'comment-1',
      author: 'Dr. Test',
      initials: 'DT',
      color: '#378FE9',
      content: content,
      createdAt: '2026-03-30T10:00:00Z',
      isMine: true,
      replies: const [],
    );
  }

  @override
  Future<CommentReply> replyComment({
    required String commentId,
    required String content,
  }) async {
    return CommentReply(
      id: 'reply-1',
      author: 'Dr. Test',
      initials: 'DT',
      color: '#378FE9',
      content: content,
      createdAt: '2026-03-30T10:00:00Z',
      isMine: true,
    );
  }

  @override
  Future<({bool success, String content})> editComment({
    required String commentId,
    required String content,
  }) async {
    return (success: true, content: content);
  }

  @override
  Future<bool> deleteComment({required String commentId}) async {
    return true;
  }
}
