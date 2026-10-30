import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../feed/domain/entities/feed_post.dart';

/// Reusable presentation card for a single feed post in DocConnect Pro.
class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final UserModel? currentUser;
  final ValueChanged<String> onLike;
  final ValueChanged<FeedPost> onOpenComments;
  final ValueChanged<FeedPost> onEdit;
  final ValueChanged<String> onDelete;

  const FeedPostCard({
    super.key,
    required this.post,
    this.currentUser,
    required this.onLike,
    required this.onOpenComments,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isExpanded = false;
  bool _isSaved = false;

  bool get _isAuthor {
    final current = widget.currentUser;
    if (current == null) return false;
    final first = current.firstName?.trim() ?? '';
    final last = current.lastName?.trim() ?? '';
    final authorName = widget.post.author.trim().toLowerCase();
    final currentName = '$first $last'.trim().toLowerCase();
    if (authorName.isNotEmpty && authorName == currentName) return true;
    final initials =
        '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
            .toLowerCase();
    return widget.post.initials.isNotEmpty &&
        widget.post.initials.toLowerCase() == initials;
  }

  void _showPostOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                _isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppColors.textPrimary,
              ),
              title: Text(_isSaved ? 'Remove from saved' : 'Save post'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isSaved = !_isSaved);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isSaved ? 'Post saved' : 'Post removed from saved',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.link_rounded,
                color: AppColors.textPrimary,
              ),
              title: const Text('Copy link to post'),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(
                  ClipboardData(
                    text: 'https://docconnect.pro/posts/${widget.post.id}',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post link copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            if (_isAuthor) ...[
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textPrimary,
                ),
                title: const Text('Edit post'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onEdit(widget.post);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Delete post',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onDelete(widget.post.id);
                },
              ),
            ],
            ListTile(
              leading: const Icon(
                Icons.flag_outlined,
                color: AppColors.textSecondary,
              ),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you. We will review this post.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagContent(String content) {
    final words = content.split(' ');
    final spans = <TextSpan>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final isHashtag = word.startsWith('#') && word.length > 1;

      spans.add(
        TextSpan(
          text: word + (i == words.length - 1 ? '' : ' '),
          style: isHashtag
              ? AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppTypography.wSemiBold,
                )
              : AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildPostTypeBadge(String typeDisplay, String type) {
    final typeUpper = type.toUpperCase();
    Color bgColor = AppColors.surfaceMuted;
    Color textColor = AppColors.textPrimary;

    if (typeDisplay.toLowerCase().contains('clinical') ||
        typeUpper == 'CASE' ||
        typeUpper == 'UPDATE') {
      bgColor = const Color(0xFFE0F2FE);
      textColor = AppColors.primary;
    } else if (typeDisplay.toLowerCase().contains('research') ||
        typeUpper == 'ARTICLE') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        typeDisplay.isNotEmpty ? typeDisplay : 'Clinical Update',
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontSize: 11,
          fontWeight: AppTypography.wSemiBold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final resolvedPhoto = UrlUtils.resolveUrl(post.photo);
    final resolvedImage = UrlUtils.resolveUrl(post.image);

    final contentText = post.content;
    final isLongContent = contentText.length > 180;
    final displayContent = (isLongContent && !_isExpanded)
        ? '${contentText.substring(0, 180)}...'
        : contentText;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header (Avatar, Author Info, Type Badge, Options Menu) ──
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
                Stack(
                  children: [
                    DoctorAvatar(
                      photoUrl: resolvedPhoto,
                      firstName: post.initials.isNotEmpty
                          ? post.initials.characters.first
                          : post.author,
                      size: 44,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    post.author,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: AppTypography.wBold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildPostTypeBadge(
                            post.postTypeDisplay,
                            post.postType,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.headline.isNotEmpty
                            ? post.headline
                            : 'Medical Professional',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTimeAgo(post.createdAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textDisabled,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.public_rounded,
                            size: 12,
                            color: AppColors.textDisabled,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Post Options Menu (Three Dots) ──────────────────────
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  tooltip: 'Post options',
                  onPressed: () => _showPostOptionsMenu(context),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          if (post.piiFlagged)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      size: 12,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'Clinical Privacy Protected',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: const Color(0xFFB45309),
                        fontWeight: AppTypography.wSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Text Content ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHashtagContent(displayContent),
                if (isLongContent && !_isExpanded)
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = true),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(
                        'see more',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTypography.wSemiBold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Image Attachment ───────────────────────────────────────
          if (resolvedImage != null && resolvedImage.isNotEmpty)
            _PostImageWidget(imageUrl: resolvedImage),

          // ── Engagement Counts Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${post.likeCount}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTypography.wMedium,
                  ),
                ),
                const Spacer(),
                if (post.commentCount > 0)
                  GestureDetector(
                    onTap: () => widget.onOpenComments(post),
                    child: Text(
                      '${post.commentCount} comments',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTypography.wMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(color: Color(0xFFE5E7EB), height: 1),

          // ── Action Buttons (Like, Comment, Save, Share) ──────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PostActionButton(
                  icon: post.liked
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_outlined,
                  label: 'Like',
                  color: post.liked
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  onTap: () => widget.onLike(post.id),
                ),
                _PostActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Comment',
                  onTap: () => widget.onOpenComments(post),
                ),
                _PostActionButton(
                  icon: _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: 'Save',
                  color: _isSaved ? AppColors.primary : AppColors.textSecondary,
                  onTap: () {
                    setState(() => _isSaved = !_isSaved);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isSaved ? 'Post saved' : 'Post removed from saved',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _PostActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: 'https://docconnect.pro/posts/${post.id}',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post link copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImageWidget extends StatelessWidget {
  final String imageUrl;

  const _PostImageWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Str = imageUrl
            .split(',')
            .last
            .replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _errorFallback(),
        );
      } catch (_) {
        return _errorFallback();
      }
    }

    return Image.network(
      imageUrl,
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 240,
          color: AppColors.surfaceMuted,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => _errorFallback(),
    );
  }

  Widget _errorFallback() {
    return Container(
      height: 120,
      color: AppColors.surfaceMuted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Image unavailable',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: AppTypography.wMedium,
                fontSize: 12,
              ),
            ),
          ],
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
