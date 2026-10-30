import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/data/datasources/feed_remote_data_source.dart';
import '../../../feed/data/repositories/feed_repository_impl.dart';
import '../../../feed/domain/usecases/get_feed_posts_usecase.dart';
import '../../../feed/domain/usecases/post_management_usecases.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_event.dart';
import '../../../feed/presentation/bloc/feed_state.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import 'edit_post_sheet.dart';
import 'feed_post_card.dart';
import 'post_composer_sheet.dart';
import 'post_detail_sheet.dart';

/// Home tab: clean LinkedIn-style professional feed wall.
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final hasHomeBloc = context.readOrNull<HomeBloc>() != null;

    final feedBlocProvider = BlocProvider(
      create: (context) {
        if (DependencyInjection.instance.isRegistered<FeedBloc>()) {
          return DependencyInjection.instance<FeedBloc>()
            ..add(const FeedStarted());
        }
        final feedRepo = FeedRepositoryImpl(
          remoteDataSource: FeedRemoteDataSourceImpl(
            apiClient: DependencyInjection.instance<ApiClient>(),
          ),
        );
        return FeedBloc(
          getFeedPosts: GetFeedPosts(feedRepo),
          createPost: CreatePost(feedRepo),
          likePost: LikePost(feedRepo),
          editPost: EditPost(feedRepo),
          deletePost: DeletePost(feedRepo),
        )..add(const FeedStarted());
      },
      child: const _FeedTabView(),
    );

    if (hasHomeBloc) {
      return feedBlocProvider;
    }

    return BlocProvider(
      create: (context) {
        if (DependencyInjection.instance.isRegistered<HomeBloc>()) {
          return DependencyInjection.instance<HomeBloc>()
            ..add(const HomeStarted());
        }
        return HomeBloc(
          getHomeData: GetHomeData(
            HomeRepositoryImpl(
              remoteDataSource: HomeRemoteDataSourceImpl(
                apiClient: DependencyInjection.instance<ApiClient>(),
              ),
            ),
          ),
        )..add(const HomeStarted());
      },
      child: feedBlocProvider,
    );
  }
}

class _FeedTabView extends StatefulWidget {
  const _FeedTabView();

  @override
  State<_FeedTabView> createState() => _FeedTabViewState();
}

class _FeedTabViewState extends State<_FeedTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 300) {
      final feedBloc = context.read<FeedBloc>();
      if (feedBloc.state.hasMore &&
          feedBloc.state.status != FeedStatus.loadingMore &&
          feedBloc.state.status != FeedStatus.loading &&
          feedBloc.state.status != FeedStatus.refreshing) {
        feedBloc.add(const FeedLoadMoreRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select<AuthBloc, UserModel?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, feedState) {
            final displayPosts = feedState.posts;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
                context.read<FeedBloc>().add(const FeedRefreshRequested());
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ── LinkedIn Quick Post Composer Bar ───────────
                  const SliverToBoxAdapter(child: _CompactPostComposerBar()),

                  if (feedState.status == FeedStatus.loading ||
                      feedState.status == FeedStatus.initial)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (feedState.status == FeedStatus.failure &&
                      feedState.posts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                feedState.error?.message ??
                                    'Failed to load feed',
                                style: AppTypography.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextButton(
                                onPressed: () {
                                  context.read<HomeBloc>().add(
                                    const HomeStarted(),
                                  );
                                  context.read<FeedBloc>().add(
                                    const FeedStarted(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (displayPosts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.article_outlined,
                                size: 44,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No posts yet',
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Be the first to share something with your network.',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // ── Full-Width Scrollable Post Wall ──────────
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return FeedPostCard(
                          post: displayPosts[index],
                          currentUser: currentUser,
                          onLike: (postId) => context.read<FeedBloc>().add(
                            FeedPostLiked(postId),
                          ),
                          onOpenComments: (post) {
                            AppBottomSheet.show(
                              context: context,
                              isScrollControlled: true,
                              child: PostDetailSheet(post: post),
                            );
                          },
                          onEdit: (post) {
                            AppBottomSheet.show(
                              context: context,
                              isScrollControlled: true,
                              child: EditPostSheet(post: post),
                            );
                          },
                          onDelete: (postId) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete post'),
                                content: const Text(
                                  'Are you sure you want to delete this post?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<FeedBloc>().add(
                                        FeedPostDeleted(postId: postId),
                                      );
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }, childCount: displayPosts.length),
                    ),
                    if (feedState.status == FeedStatus.loadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    if (feedState.hasMore &&
                        feedState.status != FeedStatus.loadingMore)
                      SliverToBoxAdapter(
                        child: _LoadMoreButton(
                          onPressed: () => context.read<FeedBloc>().add(
                            const FeedLoadMoreRequested(),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Load more posts',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: AppTypography.wSemiBold,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactPostComposerBar extends StatelessWidget {
  const _CompactPostComposerBar();

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserModel?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });
    final firstName = user?.firstName ?? 'Doctor';
    final lastName = user?.lastName;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          DoctorAvatar(
            photoUrl: UrlUtils.resolveUrl(user?.profileImage),
            firstName: firstName,
            lastName: lastName,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: InkWell(
              onTap: () => AppBottomSheet.show(
                context: context,
                isScrollControlled: true,
                child: const PostComposerSheet(),
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Share a clinical insight, case or update...',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
