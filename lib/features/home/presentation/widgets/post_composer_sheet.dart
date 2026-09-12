import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/models/user_model.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_event.dart';
import '../../../feed/presentation/bloc/post_composer_bloc.dart';
import '../../../feed/presentation/bloc/post_composer_event.dart';
import '../../../feed/presentation/bloc/post_composer_state.dart';

/// Supported post types with their display labels and icons.
enum _PostTypeOption {
  update('UPDATE', 'Update', Icons.edit_note_rounded, Color(0xFF5B3CC4)),
  caseType('CASE', 'Case', Icons.medical_information_outlined, Color(0xFFD94F4F)),
  article('ARTICLE', 'Article', Icons.article_outlined, Color(0xFFC37D16)),
  photo('PHOTO', 'Photo', Icons.photo_camera_outlined, Color(0xFF378FE9));

  const _PostTypeOption(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

/// Composer sheet for creating a new feed post.
class PostComposerSheet extends StatefulWidget {
  const PostComposerSheet({super.key});

  @override
  State<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<PostComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  UserModel? get _user {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.user;
    return null;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      context.read<PostComposerBloc>().add(PostImageSelected(picked.path));
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<PostComposerBloc>().add(PostSubmitted(text));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final firstName = user?.firstName ?? 'Me';
    final lastName = user?.lastName;

    return BlocProvider(
      create: (context) => DependencyInjection.instance<PostComposerBloc>(),
      child: BlocConsumer<PostComposerBloc, PostComposerState>(
        listenWhen: (prev, curr) => curr.status != prev.status,
        listener: (context, state) {
          if (state.status == PostComposerStatus.success) {
            Navigator.of(context).pop();
            // Refresh the feed
            context.read<FeedBloc>().add(const FeedRefreshRequested());
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Your post has been shared!'),
                  backgroundColor: AppColors.success,
                ),
              );
          } else if (state.status == PostComposerStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.error?.message ?? 'Failed to create post',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Handle ───────────────────────────────────────────────
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

                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Create a post',
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

                // ── Content area ─────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── User row ──────────────────────────────────
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstName,
                                    style: AppTypography.labelLarge,
                                  ),
                                  if (state.isCaseType && state.isAnonymous)
                                    Text(
                                      'Posting anonymously',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── Text input ────────────────────────────────
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: 6,
                          minLines: 4,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: false,
                            hintText: _getHintText(state.postType),
                          ),
                          style: AppTypography.bodyLarge,
                        ),

                        // ── Image preview ─────────────────────────────
                        if (state.imagePath != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.borderLg,
                                child: Image.file(
                                  File(state.imagePath!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: AppSpacing.xs,
                                right: AppSpacing.xs,
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<PostComposerBloc>()
                                      .add(const PostImageRemoved()),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Bottom actions ─────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
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
                      // ── Post type selector ─────────────────────────
                      Row(
                        children: _PostTypeOption.values.map((option) {
                          final isSelected = state.postType == option.value;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => context
                                  .read<PostComposerBloc>()
                                  .add(PostTypeChanged(option.value)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? option.color.withValues(alpha: 0.1)
                                      : AppColors.surfaceMuted,
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(
                                    color: isSelected
                                        ? option.color
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 20,
                                      color: isSelected
                                          ? option.color
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option.label,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isSelected
                                            ? option.color
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? AppTypography.wSemiBold
                                            : AppTypography.wMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // ── Anonymous toggle (CASE only) ───────────────
                      if (state.isCaseType) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppRadius.borderMd,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Post anonymously',
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                              Switch(
                                value: state.isAnonymous,
                                onChanged: (value) => context
                                    .read<PostComposerBloc>()
                                    .add(AnonymousToggled(value)),
                                activeThumbColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Media + Submit row ──────────────────────────
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Add image',
                            icon: const Icon(Icons.photo_library_outlined),
                            color: const Color(0xFF378FE9),
                            onPressed: state.imagePath != null
                                ? null
                                : _pickImage,
                          ),
                          IconButton(
                            tooltip: 'Take photo',
                            icon: const Icon(Icons.camera_alt_outlined),
                            color: const Color(0xFF5F9B41),
                            onPressed: state.imagePath != null
                                ? null
                                : () async {
                                    final bloc =
                                        context.read<PostComposerBloc>();
                                    final picked =
                                        await _imagePicker.pickImage(
                                      source: ImageSource.camera,
                                      maxWidth: 1920,
                                      maxHeight: 1920,
                                      imageQuality: 85,
                                    );
                                    if (picked != null && mounted) {
                                      bloc.add(
                                        PostImageSelected(picked.path),
                                      );
                                    }
                                  },
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          PrimaryButton(
                            label: 'Post',
                            icon: Icons.send_rounded,
                            isLoading:
                                state.status == PostComposerStatus.submitting,
                            onPressed:
                                _controller.text.trim().isEmpty
                                    ? null
                                    : _submit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getHintText(String postType) {
    switch (postType) {
      case 'CASE':
        return 'Describe the clinical case you want to discuss…';
      case 'ARTICLE':
        return 'Share an article or write your thoughts…';
      case 'PHOTO':
        return 'Add a caption to your photo…';
      default:
        return 'Share an update about your practice…';
    }
  }
}
