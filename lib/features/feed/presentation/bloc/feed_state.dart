import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/feed_post.dart';

enum FeedStatus { initial, loading, loaded, refreshing, loadingMore, failure, empty }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<FeedPost> posts;
  final int page;
  final bool hasMore;
  final Failure? error;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.page = 0,
    this.hasMore = false,
    this.error,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<FeedPost>? posts,
    int? page,
    bool? hasMore,
    Failure? error,
    bool clearError = false,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, posts, page, hasMore, error];
}
