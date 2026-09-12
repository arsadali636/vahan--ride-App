import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_photo.dart';
import '../../domain/entities/doctor_profile.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import 'profile_section_card.dart';

/// Profile photo card: shows the current avatar, lets the user pick a photo,
/// preview it and upload it (with retry).
class PhotoUploadSection extends StatefulWidget {
  final DoctorProfile? profile;

  const PhotoUploadSection({super.key, this.profile});

  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  DoctorPhoto? _pending;
  bool _picking = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _pending = DoctorPhoto(
          bytes: bytes,
          filename: picked.name,
          contentType: _contentTypeFor(picked),
        );
      });
    } catch (_) {
      // Picking failed (e.g. no gallery permission); keep the current photo.
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  String _contentTypeFor(XFile file) {
    if (file.mimeType != null && file.mimeType!.isNotEmpty) {
      return file.mimeType!;
    }
    return file.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
  }

  void _upload() {
    final photo = _pending;
    if (photo == null) return;
    context.read<DoctorProfileBloc>().add(
          DoctorProfilePhotoUploadRequested(photo),
        );
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final pending = _pending;

    return BlocBuilder<DoctorProfileBloc, DoctorProfileState>(
      builder: (context, state) {
        final uploading = state.isUploadingPhoto;

        return ProfileSectionCard(
          icon: Icons.account_circle_outlined,
          title: 'Profile photo',
          child: pending != null
              ? _buildPreview(pending, uploading: uploading)
              : _buildCurrent(profile, uploading: uploading),
        );
      },
    );
  }

  Widget _buildCurrent(DoctorProfile? profile, {required bool uploading}) {
    return Row(
      children: [
        DoctorAvatar(
          firstName: profile?.firstName ?? '?',
          lastName: profile?.lastName,
          size: 64,
          verified: profile?.isVerified ?? false,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photo upload is unavailable on the backend yet — your photo '
                'file is stored for later use.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlineButton(
                label: 'Choose photo',
                icon: Icons.add_a_photo_outlined,
                isLoading: uploading || _picking,
                onPressed: _chooseSource,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(DoctorPhoto photo, {required bool uploading}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            Uint8List.fromList(photo.bytes),
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: uploading ? 'Uploading…' : 'Upload photo',
                icon: Icons.upload_rounded,
                isLoading: uploading,
                onPressed: uploading ? null : _upload,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlineButton(
              label: 'Retry',
              icon: Icons.restart_alt,
              isLoading: uploading,
              onPressed: uploading ? null : _chooseSource,
            ),
          ],
        ),
      ],
    );
  }
}
