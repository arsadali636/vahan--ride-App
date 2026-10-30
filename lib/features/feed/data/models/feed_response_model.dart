import 'package:equatable/equatable.dart';

import '../../domain/entities/feed_post.dart';
import 'feed_post_model.dart';

/// Paginated envelope returned by `GET /api/v1/feed/`.
class FeedResponseModel extends Equatable {
  final List<FeedPostModel> posts;
  final int page;
  final int pageSize;
  final bool hasMore;

  const FeedResponseModel({
    required this.posts,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory FeedResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedResponseModel(
      posts: (json['posts'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => FeedPostModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  List<FeedPost> toEntities() {
    return posts.map((e) => e.toEntity()).toList();
  }

  @override
  List<Object?> get props => [posts, page, pageSize, hasMore];
}
