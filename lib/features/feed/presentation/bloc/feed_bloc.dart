import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/usecases/get_feed_posts_usecase.dart';
import '../../domain/usecases/post_management_usecases.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required this.getFeedPosts,
    required this.createPost,
    required this.likePost,
    required this.editPost,
    required this.deletePost,
  }) : _currentPosts = [],
       super(const FeedState()) {
    on<FeedStarted>(_onStarted);
    on<FeedLoadMoreRequested>(_onLoadMoreRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedPostLiked>(_onPostLiked);
    on<FeedPostEdited>(_onFeedPostEdited);
    on<FeedPostDeleted>(_onFeedPostDeleted);
  }

  static const int _pageSize = 10;

  final GetFeedPosts getFeedPosts;
  final CreatePost createPost;
  final LikePost likePost;
  final EditPost editPost;
  final DeletePost deletePost;

  final List<FeedPost> _currentPosts;

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading, clearError: true));
    await _fetchPage(emit, page: 1);
  }

  Future<void> _onLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (!state.hasMore ||
        state.status == FeedStatus.loadingMore ||
        state.status == FeedStatus.loading ||
        state.status == FeedStatus.refreshing) {
      return;
    }
    emit(state.copyWith(status: FeedStatus.loadingMore));
    await _fetchPage(emit, page: state.page + 1);
  }

  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.refreshing));
    await _fetchPage(emit, page: 1);
  }

  Future<void> _onPostLiked(
    FeedPostLiked event,
    Emitter<FeedState> emit,
  ) async {
    // Optimistically toggle the like state in the local list.
    final updatedPosts = state.posts.map((post) {
      if (post.id != event.postId) return post;
      final newLiked = !post.liked;
      final newCount = newLiked ? post.likeCount + 1 : post.likeCount - 1;
      return post.copyWith(
        liked: newLiked,
        likeCount: newCount < 0 ? 0 : newCount,
      );
    }).toList();

    emit(state.copyWith(posts: updatedPosts));

    // Call the API in the background; reconcile on response.
    try {
      final result = await likePost(postId: event.postId);
      final reconciled = state.posts.map((post) {
        if (post.id != event.postId) return post;
        return post.copyWith(liked: result.liked, likeCount: result.count);
      }).toList();
      emit(state.copyWith(posts: reconciled));
    } on Failure catch (_) {
      // On failure, revert the optimistic update by toggling back.
      final reverted = state.posts.map((post) {
        if (post.id != event.postId) return post;
        final revertedLiked = !post.liked;
        final revertedCount = revertedLiked
            ? post.likeCount + 1
            : post.likeCount - 1;
        return post.copyWith(
          liked: revertedLiked,
          likeCount: revertedCount < 0 ? 0 : revertedCount,
        );
      }).toList();
      emit(state.copyWith(posts: reverted));
    }
  }

  Future<void> _onFeedPostEdited(
    FeedPostEdited event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final result = await editPost(
        postId: event.postId,
        content: event.content,
        removeImage: event.removeImage,
        imageFile: event.imageFile,
      );
      final index = _currentPosts.indexWhere((p) => p.id == event.postId);
      if (index != -1) {
        final updatedPost = _currentPosts[index].copyWith(
          content: result.content,
          image: result.image ?? _currentPosts[index].image,
        );
        _currentPosts[index] = updatedPost;
      }
      emit(
        state.copyWith(
          status: FeedStatus.loaded,
          posts: List.unmodifiable(_currentPosts),
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(error: e, clearError: true));
    }
  }

  Future<void> _onFeedPostDeleted(
    FeedPostDeleted event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await deletePost(postId: event.postId);
      _currentPosts.removeWhere((p) => p.id == event.postId);
      emit(
        state.copyWith(
          status: FeedStatus.loaded,
          posts: List.unmodifiable(_currentPosts),
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(error: e, clearError: true));
    }
  }

  Future<void> _fetchPage(Emitter<FeedState> emit, {required int page}) async {
    try {
      final posts = await getFeedPosts(page: page, pageSize: _pageSize);
      final isFirstPage = page == 1;
      if (isFirstPage) {
        _currentPosts
          ..clear()
          ..addAll(posts);
      } else {
        _currentPosts.addAll(posts);
      }

      emit(
        state.copyWith(
          status: _currentPosts.isEmpty ? FeedStatus.empty : FeedStatus.loaded,
          posts: List.unmodifiable(_currentPosts),
          page: page,
          hasMore: getFeedPosts.hasMore,
          clearError: true,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, error: e));
    }
  }
}
