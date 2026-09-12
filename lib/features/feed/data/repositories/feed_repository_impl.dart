import 'dart:io';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/comment_reply.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required this.remoteDataSource});

  final FeedRemoteDataSource remoteDataSource;
  bool _hasMore = false;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<List<FeedPost>> getFeedPosts({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await remoteDataSource.getFeedPosts(
        page: page,
        pageSize: pageSize,
      );
      _hasMore = response.hasMore;
      return response.toEntities();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<void> createPost({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    try {
      await remoteDataSource.createPost(
        content: content,
        postType: postType,
        isAnonymous: isAnonymous,
        imageFile: imageFile,
      );
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<({bool liked, int count})> likePost({required String postId}) async {
    try {
      final response = await remoteDataSource.likePost(postId: postId);
      return (liked: response.liked, count: response.count);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<({bool success, String content, String? image})> editPost({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  }) async {
    try {
      final result = await remoteDataSource.editPost(
        postId: postId,
        content: content,
        removeImage: removeImage,
        imageFile: imageFile,
      );
      return (success: result.success, content: result.content, image: result.image);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<bool> deletePost({required String postId}) async {
    try {
      return await remoteDataSource.deletePost(postId: postId);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<List<Comment>> getComments({required String postId}) async {
    try {
      final response = await remoteDataSource.getComments(postId: postId);
      return response.toEntities();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<Comment> postComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await remoteDataSource.postComment(
        postId: postId,
        content: content,
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<CommentReply> replyComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await remoteDataSource.replyComment(
        commentId: commentId,
        content: content,
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<({bool success, String content})> editComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final result = await remoteDataSource.editComment(
        commentId: commentId,
        content: content,
      );
      return (success: result.success, content: result.content);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<bool> deleteComment({required String commentId}) async {
    try {
      return await remoteDataSource.deleteComment(commentId: commentId);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }
}
