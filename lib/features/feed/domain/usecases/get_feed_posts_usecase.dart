import 'dart:io';

import '../entities/feed_post.dart';
import '../repositories/feed_repository.dart';

/// Fetches a page of feed posts.
class GetFeedPosts {
  GetFeedPosts(this._repository);

  final FeedRepository _repository;

  Future<List<FeedPost>> call({required int page, required int pageSize}) {
    return _repository.getFeedPosts(page: page, pageSize: pageSize);
  }

  bool get hasMore => _repository.hasMore;
}

/// Creates a new feed post.
class CreatePost {
  CreatePost(this._repository);

  final FeedRepository _repository;

  Future<void> call({
    required String content,
    required String postType,
    required bool isAnonymous,
    File? imageFile,
    List<int>? imageBytes,
    String? imageName,
  }) {
    return _repository.createPost(
      content: content,
      postType: postType,
      isAnonymous: isAnonymous,
      imageFile: imageFile,
      imageBytes: imageBytes,
      imageName: imageName,
    );
  }
}

/// Toggles like on a post. Returns the server-confirmed `{liked, count}`.
class LikePost {
  LikePost(this._repository);

  final FeedRepository _repository;

  Future<({bool liked, int count})> call({required String postId}) {
    return _repository.likePost(postId: postId);
  }
}
