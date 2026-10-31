import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/doctor_avatar.dart';
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

/// Supported post types aligning with the backend OpenAPI specification:
/// UPDATE (default) | CASE | ARTICLE | PHOTO
enum _PostTypeOption {
  update(
    'UPDATE',
    'Update',
    Icons.campaign_outlined,
    Color(0xFF0066FF),
    'Share a clinical update or thought...',
  ),
  caseType(
    'CASE',
    'Clinical Case',
    Icons.medical_information_outlined,
    Color(0xFF059669),
    'Describe the clinical case details (no patient PII)...',
  ),
  article(
    'ARTICLE',
    'Article',
    Icons.article_outlined,
    Color(0xFFD97706),
    'Share a medical paper, findings or clinical review...',
  ),
  photo(
    'PHOTO',
    'Media / Scan',
    Icons.photo_library_outlined,
    Color(0xFF7C3AED),
    'Share clinical imaging, diagrams or photographs...',
  );

  const _PostTypeOption(
    this.value,
    this.label,
    this.icon,
    this.color,
    this.hint,
  );

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String hint;
}

/// Premium LinkedIn-style composer sheet for DocConnect Pro.
class PostComposerSheet extends StatefulWidget {
  final String? initialPostType;
  final PostComposerBloc? composerBloc;

  const PostComposerSheet({super.key, this.initialPostType, this.composerBloc});

  @override
  State<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends State<PostComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  late final PostComposerBloc _composerBloc;
  bool _createdLocalBloc = false;

  String _audience = 'Anyone';
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.requestFocus();

    if (widget.composerBloc != null) {
      _composerBloc = widget.composerBloc!;
    } else {
      _composerBloc = DependencyInjection.instance<PostComposerBloc>();
      _createdLocalBloc = true;
    }
    if (widget.initialPostType != null) {
      _composerBloc.add(PostTypeChanged(widget.initialPostType!));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    if (_createdLocalBloc) {
      _composerBloc.close();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  UserModel? get _user {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.user;
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      _composerBloc.add(
        PostImageSelected(
          picked.path,
          imageName: picked.name,
          imageBytes: bytes,
        ),
      );
    }
  }

  void _showMediaSourcePicker() {
    showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF059669),
                ),
                title: const Text('Take a photo / scan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAudiencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Who can see your post?',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: AppTypography.wBold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.public_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Anyone'),
              subtitle: const Text('Anyone on DocConnect Pro'),
              trailing: _audience == 'Anyone'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _audience = 'Anyone');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.people_outline_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Connections only'),
              subtitle: const Text('Only doctors in your professional network'),
              trailing: _audience == 'Connections only'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _audience = 'Connections only');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.verified_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Verified Doctors only'),
              subtitle: const Text('Only licensed & verified practitioners'),
              trailing: _audience == 'Verified Doctors only'
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _audience = 'Verified Doctors only');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _runProofread() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    // Clean up excessive whitespace while preserving paragraphs
    final cleaned = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n\n');

    _controller.text = cleaned;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formatting polished and cleaned.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _composerBloc.add(PostSubmitted(text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _composerBloc,
      child: _buildConsumer(context),
    );
  }

  Widget _buildConsumer(BuildContext context) {
    final user = _user;
    final firstName = user?.firstName ?? 'Doctor';
    final lastName = user?.lastName;
    final hasContent = _controller.text.trim().isNotEmpty;

    return BlocConsumer<PostComposerBloc, PostComposerState>(
      listenWhen: (prev, curr) => curr.status != prev.status,
      listener: (context, state) {
        if (state.status == PostComposerStatus.success) {
          Navigator.of(context).pop();
          context.readOrNull<FeedBloc>()?.add(const FeedRefreshRequested());
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
                content: Text(state.error?.message ?? 'Failed to create post'),
                backgroundColor: AppColors.error,
              ),
            );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == PostComposerStatus.submitting;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag Indicator ───────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── LinkedIn Top Navigation Bar (Close, Avatar, Audience, Clock, Post) ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    // Close 'X'
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // User Avatar
                    DoctorAvatar(
                      photoUrl: UrlUtils.resolveUrl(user?.profileImage),
                      firstName: firstName,
                      lastName: lastName,
                      size: 38,
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Audience selector + subtitle (LinkedIn style)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _showAudiencePicker,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _audience,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: AppTypography.wSemiBold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add collaborators',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Schedule / Clock icon
                    IconButton(
                      tooltip: 'Schedule post',
                      icon: const Icon(
                        Icons.access_time_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scheduling will be available soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Post Button (LinkedIn pill style)
                    ElevatedButton(
                      onPressed: (hasContent && !isSubmitting) ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasContent
                            ? AppColors.primary
                            : const Color(0xFFE5E7EB),
                        foregroundColor: hasContent
                            ? Colors.white
                            : AppColors.textDisabled,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        minimumSize: const Size(60, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Post',
                              style: AppTypography.labelLarge.copyWith(
                                color: hasContent
                                    ? Colors.white
                                    : AppColors.textDisabled,
                                fontWeight: AppTypography.wBold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // ── Optional Dismissible Collaborative Guidance Banner ──
              if (_showBanner)
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: const Color(0xFFCCE4FF)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collaborative clinical posts are live!',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: AppTypography.wBold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Discuss cases and research with verified doctors across your specialty.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showBanner = false),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Medical Post Type Pills (UPDATE, CASE, ARTICLE, PHOTO) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _PostTypeOption.values.map((option) {
                      final isSelected = state.postType == option.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: InkWell(
                          onTap: () => context.read<PostComposerBloc>().add(
                            PostTypeChanged(option.value),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? option.color.withValues(alpha: 0.12)
                                  : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? option.color
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  option.icon,
                                  size: 15,
                                  color: isSelected
                                      ? option.color
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  option.label,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? option.color
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? AppTypography.wBold
                                        : AppTypography.wMedium,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Mandatory Case Requirements Banner (when CASE selected) ──
              if (state.isCaseType)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 18,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Patient Privacy Confirmed: Ensure all personal identifiers are removed.',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFF047857),
                            fontSize: 11,
                            fontWeight: AppTypography.wSemiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Main Content Area ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 6,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          filled: false,
                          hintText: 'Share your thoughts ...',
                          hintStyle: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 17,
                          ),
                        ),
                        style: AppTypography.bodyLarge.copyWith(fontSize: 17),
                      ),

                      // Image attachment preview
                      if (state.hasImage) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.borderLg,
                              child: state.imageBytes != null
                                  ? Image.memory(
                                      Uint8List.fromList(state.imageBytes!),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : (kIsWeb
                                        ? Image.network(
                                            state.imagePath!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(state.imagePath!),
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )),
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

                      // Anonymous posting switch (CASE only)
                      if (state.isCaseType) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Post anonymously',
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: AppTypography.wSemiBold,
                                      ),
                                    ),
                                    Text(
                                      'Your name will be hidden from other practitioners',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
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
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              // ── Inline Error Banner ──────────────────────────────────
              if (state.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          state.error?.message ?? 'Failed to create post',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── LinkedIn Bottom Toolbar (Proofread, Image, Add) ────────
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 0.8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    // "Proofread" Pill Button (exact match to LinkedIn Screenshot 2!)
                    InkWell(
                      onTap: _runProofread,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.textPrimary,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Proofread',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: AppTypography.wBold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Media / Gallery Icon Button
                    IconButton(
                      tooltip: 'Add media',
                      icon: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      onPressed: state.imagePath != null
                          ? null
                          : _showMediaSourcePicker,
                    ),

                    // More options (+) button
                    IconButton(
                      tooltip: 'More options',
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        _showMediaSourcePicker();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
