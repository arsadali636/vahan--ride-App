import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/create_post_response_model.dart';
import '../models/delete_response_model.dart';
import '../models/edit_comment_response_model.dart';
import '../models/edit_post_response_model.dart';
import '../models/feed_response_model.dart';
import '../models/get_comments_response_model.dart';
import '../models/like_post_response_model.dart';
import '../models/post_comment_response_model.dart';
import '../models/reply_comment_response_model.dart';

/// Remote data source for feed endpoints.
abstract class FeedRemoteDataSource {
  /// Fetches a page of feed posts.
  Future<FeedResponseModel> getFeedPosts({
    required int page,
    required int pageSize,
  });

  /// Creates a new feed post with optional image.
  Future<CreatePostResponseModel> createPost({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
  });

  /// Toggles like on a post. Returns the server-confirmed like state and count.
  Future<LikePostResponseModel> likePost({required String postId});

  /// Edits an existing post.
  Future<EditPostResponseModel> editPost({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  });

  /// Deletes a post by id.
  Future<bool> deletePost({required String postId});

  /// Fetches comments for a post.
  Future<GetCommentsResponseModel> getComments({required String postId});

  /// Posts a comment on a post.
  Future<PostCommentResponseModel> postComment({
    required String postId,
    required String content,
  });

  /// Replies to a comment.
  Future<ReplyCommentResponseModel> replyComment({
    required String commentId,
    required String content,
  });

  /// Edits a comment.
  Future<EditCommentResponseModel> editComment({
    required String commentId,
    required String content,
  });

  /// Deletes a comment by id.
  Future<bool> deleteComment({required String commentId});
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<FeedResponseModel> getFeedPosts({
    required int page,
    required int pageSize,
  }) async {
    final data = await apiClient.get(
      ApiEndpoints.feed,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return FeedResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<CreatePostResponseModel> createPost({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    final formData = <String, dynamic>{
      'content': content,
      'post_type': postType,
      'is_anonymous': isAnonymous.toString(),
    };

    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      final contentType = _guessContentType(fileName);
      formData['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType.parse(contentType),
      );
    }

    final data = await apiClient.post(
      ApiEndpoints.feedPosts,
      data: FormData.fromMap(formData),
    );
    return CreatePostResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<LikePostResponseModel> likePost({required String postId}) async {
    final data = await apiClient.post(
      ApiEndpoints.feedPostLikeById(postId),
      data: <String, dynamic>{},
    );
    return LikePostResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<EditPostResponseModel> editPost({
    required String postId,
    required String content,
    bool removeImage = false,
    File? imageFile,
  }) async {
    final url = '${ApiEndpoints.editPost}/$postId/';
    FormData? formData;
    if (imageFile != null) {
      final file = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
      formData = FormData.fromMap({
        'content': content,
        'remove_image': removeImage,
        'image': file,
      });
    } else {
      formData = FormData.fromMap({
        'content': content,
        'remove_image': removeImage,
      });
    }
    final data = await apiClient.patch(
      url,
      data: formData,
    );
    return EditPostResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<bool> deletePost({required String postId}) async {
    final url = '${ApiEndpoints.deletePost}/$postId/';
    final data = await apiClient.delete(url);
    final deleteResponse = DeleteResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
    return deleteResponse.success;
  }

  @override
  Future<GetCommentsResponseModel> getComments({
    required String postId,
  }) async {
    final url = '${ApiEndpoints.getComments}/$postId/comments/';
    final data = await apiClient.get(url);
    return GetCommentsResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<PostCommentResponseModel> postComment({
    required String postId,
    required String content,
  }) async {
    final url = '${ApiEndpoints.postComment}/$postId/comments/';
    final data = await apiClient.post(
      url,
      data: FormData.fromMap({'content': content}),
    );
    return PostCommentResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<ReplyCommentResponseModel> replyComment({
    required String commentId,
    required String content,
  }) async {
    final url = '${ApiEndpoints.replyComment}/$commentId/reply/';
    final data = await apiClient.post(
      url,
      data: FormData.fromMap({'content': content}),
    );
    return ReplyCommentResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<EditCommentResponseModel> editComment({
    required String commentId,
    required String content,
  }) async {
    final url = '${ApiEndpoints.editComment}/$commentId/';
    final data = await apiClient.patch(
      url,
      data: FormData.fromMap({'content': content}),
    );
    return EditCommentResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<bool> deleteComment({required String commentId}) async {
    final url = '${ApiEndpoints.deleteComment}/$commentId/';
    final data = await apiClient.delete(url);
    final deleteResponse = DeleteResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
    return deleteResponse.success;
  }

  String _guessContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
