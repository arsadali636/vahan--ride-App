import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/user_model.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/domain/entities/feed_post.dart';
import '../../../feed/presentation/bloc/feed_bloc.dart';
import '../../../feed/presentation/bloc/feed_event.dart';

class EditPostSheet extends StatefulWidget {
  final FeedPost post;

  const EditPostSheet({super.key, required this.post});

  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  String? _newImagePath;
  bool _removeExistingImage = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content);
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

  bool get _hasExistingImage =>
      widget.post.image != null && widget.post.image!.isNotEmpty;

  bool get _hasImage =>
      _hasExistingImage && !_removeExistingImage || _newImagePath != null;

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
      setState(() {
        _newImagePath = picked.path;
        _removeExistingImage = false;
      });
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    context.read<FeedBloc>().add(
      FeedPostEdited(
        postId: widget.post.id,
        content: text,
        removeImage: _removeExistingImage,
        imageFile: _newImagePath != null ? File(_newImagePath!) : null,
      ),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Post updated!'),
          backgroundColor: AppColors.success,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final firstName = user?.firstName ?? 'Me';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text('Edit post', style: AppTypography.titleLarge),
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
                  Row(
                    children: [
                      DoctorAvatar(
                        photoUrl: user?.profileImage,
                        firstName: firstName,
                        size: 44,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(firstName, style: AppTypography.labelLarge),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 6,
                    minLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: false,
                      hintText: 'Edit your post...',
                    ),
                    style: AppTypography.bodyLarge,
                  ),

                  // ── New image preview ──
                  if (_newImagePath != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.borderLg,
                          child: Image.file(
                            File(_newImagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: GestureDetector(
                            onTap: () => setState(() => _newImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
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

                  // ── Existing image with remove checkbox ──
                  if (_hasExistingImage && _newImagePath == null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.borderLg,
                          child: Image.network(
                            widget.post.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
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
                                ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: GestureDetector(
                            onTap: () => setState(
                              () =>
                                  _removeExistingImage = !_removeExistingImage,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: _removeExistingImage
                                    ? AppColors.error
                                    : Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _removeExistingImage
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_removeExistingImage)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Image will be removed',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom actions ──
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
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Add image',
                  icon: const Icon(Icons.photo_library_outlined),
                  color: const Color(0xFF378FE9),
                  onPressed: (_hasImage) ? null : _pickImage,
                ),
                IconButton(
                  tooltip: 'Take photo',
                  icon: const Icon(Icons.camera_alt_outlined),
                  color: const Color(0xFF5F9B41),
                  onPressed: (_hasImage)
                      ? null
                      : () async {
                          final picked = await _imagePicker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 1920,
                            maxHeight: 1920,
                            imageQuality: 85,
                          );
                          if (picked != null && mounted) {
                            setState(() => _newImagePath = picked.path);
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
                  label: 'Update',
                  icon: Icons.check_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _controller.text.trim().isEmpty ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
