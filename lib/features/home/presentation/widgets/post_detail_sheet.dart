// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/domain/entities/comment.dart';
import '../../../feed/domain/entities/comment_reply.dart';
import '../../../feed/domain/entities/feed_post.dart';
import '../../../feed/presentation/bloc/comment_bloc.dart';
import '../../../feed/presentation/bloc/comment_event.dart';
import '../../../feed/presentation/bloc/comment_state.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_event.dart';

class PostDetailSheet extends StatefulWidget {
  final FeedPost post;

  const PostDetailSheet({super.key, required this.post});

  @override
  State<PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<PostDetailSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyToCommentId;
  String? _replyToAuthor;
  String? _editingCommentId;
  String? _editingReplyId;
  String? _editingReplyParentId;
  String? get currentUserId {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.user?.id;
    return null;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String author) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToAuthor = author;
      _editingCommentId = null;
      _editingReplyId = null;
      _editingReplyParentId = null;
    });
    _commentController.clear();
    _commentFocusNode.requestFocus();
  }

  void _startEditComment(String commentId, String content) {
    setState(() {
      _editingCommentId = commentId;
      _replyToCommentId = null;
      _replyToAuthor = null;
      _editingReplyId = null;
      _editingReplyParentId = null;
    });
    _commentController.text = content;
    _commentFocusNode.requestFocus();
  }

  void _startEditReply(String replyId, String parentId, String content) {
    setState(() {
      _editingReplyId = replyId;
      _editingReplyParentId = parentId;
      _replyToCommentId = null;
      _replyToAuthor = null;
      _editingCommentId = null;
    });
    _commentController.text = content;
    _commentFocusNode.requestFocus();
  }

  void _clearEditing() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthor = null;
      _editingCommentId = null;
      _editingReplyId = null;
      _editingReplyParentId = null;
    });
    _commentController.clear();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_editingCommentId != null) {
      context.read<CommentBloc>().add(
            CommentEdited(commentId: _editingCommentId!, content: text),
          );
      _commentController.clear();
      _clearEditing();
    } else if (_editingReplyId != null) {
      context.read<CommentBloc>().add(
            CommentReplyEdited(replyId: _editingReplyId!, content: text),
          );
      _commentController.clear();
      _clearEditing();
    } else if (_replyToCommentId != null) {
      context.read<CommentBloc>().add(
            CommentReplySubmitted(
              commentId: _replyToCommentId!,
              content: text,
            ),
          );
      _commentController.clear();
      _clearEditing();
    } else {
      context.read<CommentBloc>().add(
            CommentSubmitted(postId: widget.post.id, content: text),
          );
      _commentController.clear();
    }
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommentBloc>().add(
                    CommentDeleted(commentId: commentId),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _deleteReply(String replyId, String parentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommentBloc>().add(
                    CommentReplyDeleted(
                      replyId: replyId,
                      commentId: parentId,
                    ),
                  );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjection.instance<CommentBloc>()
        ..add(CommentStarted(postId: widget.post.id)),
      child: BlocListener<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error?.message ?? 'Something went wrong'),
                  backgroundColor: AppColors.error,
                ),
              );
            context.read<CommentBloc>().add(const CommentClearedError());
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderCircular,
                  ),
                ),
              ),
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Text(
                      'Post',
                      style: AppTypography.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // ── Content ──
              Flexible(
                child: CustomScrollView(
                  slivers: [
                    // ── Post card ──
                    SliverToBoxAdapter(
                      child: _PostHeader(post: widget.post),
                    ),
                    // ── Comments ──
                    BlocBuilder<CommentBloc, CommentState>(
                      builder: (context, state) {
                        if (state.status == CommentStatus.loading) {
                          return const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (state.comments.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'No comments yet',
                                      style: AppTypography.titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Be the first to comment on this post.',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final comment = state.comments[index];
                              return _CommentTile(
                                comment: comment,
                                currentUserId: currentUserId,
                                onReply: () => _startReply(
                                  comment.id,
                                  comment.author,
                                ),
                                onEdit: () => _startEditComment(
                                  comment.id,
                                  comment.content,
                                ),
                                onDelete: () => _deleteComment(comment.id),
                                onReplyEdit: (reply) => _startEditReply(
                                  reply.id,
                                  comment.id,
                                  reply.content,
                                ),
                                onReplyDelete: (reply) => _deleteReply(
                                  reply.id,
                                  comment.id,
                                ),
                              );
                            },
                            childCount: state.comments.length,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Comment input ──
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_replyToCommentId != null || _editingCommentId != null || _editingReplyId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _editingCommentId != null || _editingReplyId != null
                                  ? Icons.edit_rounded
                                  : Icons.reply_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _editingCommentId != null
                                    ? 'Editing comment'
                                    : _editingReplyId != null
                                        ? 'Editing reply'
                                        : 'Replying to $_replyToAuthor',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _clearEditing,
                              icon: const Icon(Icons.close_rounded, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            decoration: InputDecoration(
                              hintText: _editingCommentId != null || _editingReplyId != null
                                  ? 'Edit your comment...'
                                  : 'Add a comment...',
                              hintStyle: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textDisabled,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                            style: AppTypography.bodyMedium,
                            maxLines: 3,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
                        IconButton(
                          onPressed: _submitComment,
                          icon: Icon(
                            Icons.send_rounded,
                            color: _commentController.text.trim().isEmpty
                                ? AppColors.textDisabled
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Post header ───────────────────────────────────────────────────────────
class _PostHeader extends StatelessWidget {
  final FeedPost post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
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
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(post.content, style: AppTypography.bodyLarge),
        ),
        if (post.image != null && post.image!.isNotEmpty)
          _PostDetailImage(imageUrl: post.image!),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.thumb_up_alt_rounded,
                size: 16,
                color: post.liked
                    ? const Color(0xFF378FE9)
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('${post.likeCount}', style: AppTypography.bodySmall),
              const Spacer(),
              if (post.commentCount > 0)
                Text(
                  '${post.commentCount} comments',
                  style: AppTypography.bodySmall,
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
                onTap: () {
                  context.read<FeedBloc>().add(FeedPostLiked(post.id));
                },
              ),
              _PostAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comment',
                onTap: () {},
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
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}

/// ─── Comment tile ──────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String? currentUserId;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<CommentReply> onReplyEdit;
  final ValueChanged<CommentReply> onReplyDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onReplyEdit,
    required this.onReplyDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = comment.isMine;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorAvatar(
                photoUrl: comment.photo,
                firstName: comment.initials.isNotEmpty
                    ? comment.initials.characters.first
                    : comment.author,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: AppTypography.wSemiBold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                        if (isMine) ...[
                          const Spacer(),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') onEdit();
                              if (value == 'delete') onDelete();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(comment.content, style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTypography.wSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Replies ──
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DoctorAvatar(
                          photoUrl: reply.photo,
                          firstName: reply.initials.isNotEmpty
                              ? reply.initials.characters.first
                              : reply.author,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply.author,
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: AppTypography.wSemiBold,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    _formatTimeAgo(reply.createdAt),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textDisabled,
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (reply.isMine) ...[
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') onReplyEdit(reply);
                                        if (value == 'delete') {
                                          onReplyDelete(reply);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete',
                                              style: TextStyle(
                                                  color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                reply.content,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
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

class _PostDetailImage extends StatelessWidget {
  final String imageUrl;

  const _PostDetailImage({required this.imageUrl});

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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  } catch (_) {
    return isoString;
  }
}
