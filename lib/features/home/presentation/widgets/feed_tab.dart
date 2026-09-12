import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/models/user_model.dart';
import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/domain/entities/feed_post.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_event.dart';
import '../../../feed/presentation/bloc/feed_state.dart';
import 'edit_post_sheet.dart';
import 'post_composer_sheet.dart';
import 'post_detail_sheet.dart';

/// Home tab: the professional feed.
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.instance<FeedBloc>()
        ..add(const FeedStarted()),
      child: const _FeedTabView(),
    );
  }
}

class _FeedTabView extends StatelessWidget {
  const _FeedTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MedNexus',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.wBold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Messages',
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FeedBloc>().add(const FeedRefreshRequested());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const _PostComposerCard(),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
                if (state.status == FeedStatus.loading ||
                    state.status == FeedStatus.initial)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == FeedStatus.failure)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            state.error?.message ?? 'Failed to load feed',
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => context
                                .read<FeedBloc>()
                                .add(const FeedStarted()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.status == FeedStatus.empty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
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
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _FeedPostCard(
                          post: state.posts[index],
                          onLike: (postId) => context
                              .read<FeedBloc>()
                              .add(FeedPostLiked(postId)),
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
                      },
                      childCount: state.posts.length,
                    ),
                  ),
                  if (state.status == FeedStatus.loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  if (state.hasMore &&
                      state.status != FeedStatus.loadingMore)
                    SliverToBoxAdapter(
                      child: _LoadMoreButton(
                        onPressed: () => context
                            .read<FeedBloc>()
                            .add(const FeedLoadMoreRequested()),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          child: const Text('Load more'),
        ),
      ),
    );
  }
}

/// The "Start a post" composer entry that opens the composer sheet.
class _PostComposerCard extends StatelessWidget {
  const _PostComposerCard();

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserModel?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });
    final firstName = user?.firstName ?? 'Doctor';
    final lastName = user?.lastName;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DoctorAvatar(
                photoUrl: user?.profileImage,
                firstName: firstName,
                lastName: lastName,
                size: 44,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: () => AppBottomSheet.show(
                    context: context,
                    isScrollControlled: true,
                    child: const PostComposerSheet(),
                  ),
                  borderRadius: AppRadius.borderCircular,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadius.borderCircular,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Start a post',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ComposerAction(
                icon: Icons.photo_library_outlined,
                label: 'Photo',
                color: const Color(0xFF378FE9),
              ),
              _ComposerAction(
                icon: Icons.videocam_outlined,
                label: 'Video',
                color: const Color(0xFF5F9B41),
              ),
              _ComposerAction(
                icon: Icons.event_note_outlined,
                label: 'Event',
                color: const Color(0xFFC37D16),
              ),
              _ComposerAction(
                icon: Icons.article_outlined,
                label: 'Article',
                color: const Color(0xFFE06847),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.wSemiBold,
          ),
        ),
      ],
    );
  }
}

String _formatTimeAgo(String isoString) {
  if (isoString.isEmpty) return '';
  try {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  } catch (_) {
    return isoString;
  }
}

class _FeedPostCard extends StatelessWidget {
  final FeedPost post;
  final ValueChanged<String> onLike;
  final ValueChanged<FeedPost> onOpenComments;
  final ValueChanged<FeedPost> onEdit;
  final ValueChanged<String> onDelete;

  const _FeedPostCard({
    required this.post,
    required this.onLike,
    required this.onOpenComments,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<AuthBloc, String?>((bloc) {
      final state = bloc.state;
      if (state is AuthAuthenticated) return state.user?.id;
      return null;
    });
    final isOwn = currentUserId != null && post.authorId == currentUserId;

    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  photoUrl: post.photo,
                  firstName: post.initials.isNotEmpty
                      ? post.initials.characters.first
                      : post.author,
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: AppTypography.titleSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        post.headline,
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit(post);
                    if (value == 'delete') onDelete(post.id);
                  },
                  itemBuilder: (_) {
                    final items = <PopupMenuEntry<String>>[];
                    if (isOwn) {
                      items.addAll(const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit post'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete post',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ]);
                    }
                    return items;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Text(post.content, style: AppTypography.bodyLarge),
          ),
          if (post.image != null && post.image!.isNotEmpty)
            _PostImage(imageUrl: post.image!),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(
                  post.liked
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_rounded,
                  size: 16,
                  color: post.liked
                      ? const Color(0xFF378FE9)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${post.likeCount}',
                  style: AppTypography.bodySmall,
                ),
                const Spacer(),
                if (post.commentCount > 0)
                  GestureDetector(
                    onTap: () => onOpenComments(post),
                    child: Text(
                      '${post.commentCount} comments',
                      style: AppTypography.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostAction(
                  icon: post.liked
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: post.liked ? const Color(0xFF378FE9) : null,
                  onTap: () => onLike(post.id),
                ),
                _PostAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Comment',
                  onTap: () => onOpenComments(post),
                ),
                _PostAction(
                  icon: Icons.reply_outlined,
                  label: 'Share',
                ),
                _PostAction(
                  icon: Icons.send_outlined,
                  label: 'Send',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadius.borderLg,
              ),
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _PostAction({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color ?? AppColors.textSecondary,
                fontWeight: AppTypography.wSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
