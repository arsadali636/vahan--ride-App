import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_experience.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_qualification.dart';
import '../../domain/entities/doctor_registration.dart';

/// Coarse lifecycle of the profile screen.
enum DoctorProfileStatus {
  /// Nothing has been loaded yet.
  initial,

  /// Initial load is in flight.
  loading,

  /// Profile (and sub-resources) loaded and displayed.
  loaded,

  /// Profile creation is in flight.
  creating,

  /// Profile update is in flight.
  updating,

  /// Photo upload is in flight.
  uploadingPhoto,

  /// Pull-to-refresh is in flight while showing stale data.
  refreshing,

  /// The last mutation succeeded (transient, drives a SnackBar).
  success,

  /// The last action failed.
  failure,
}

/// Single source of truth for the doctor professional profile screen.
class DoctorProfileState extends Equatable {
  final DoctorProfileStatus status;
  final DoctorProfile? profile;
  final Failure? failure;
  final List<DoctorQualification> qualifications;
  final List<DoctorRegistration> registrations;
  final List<DoctorExperience> experiences;
  final bool profileCreated;
  final String? message;

  const DoctorProfileState({
    this.status = DoctorProfileStatus.initial,
    this.profile,
    this.failure,
    this.qualifications = const [],
    this.registrations = const [],
    this.experiences = const [],
    this.profileCreated = false,
    this.message,
  });

  bool get isLoading => status == DoctorProfileStatus.loading;

  bool get isUploadingPhoto => status == DoctorProfileStatus.uploadingPhoto;

  bool get hasProfile => profile != null && profile!.firstName.isNotEmpty;

  /// True when the account has no professional profile yet: either the backend
  /// reported `profile_created: false` or `GET /me/` returned 404.
  bool get needsCompletion => !profileCreated && !hasProfile;

  DoctorProfileState copyWith({
    DoctorProfileStatus? status,
    DoctorProfile? profile,
    Failure? failure,
    List<DoctorQualification>? qualifications,
    List<DoctorRegistration>? registrations,
    List<DoctorExperience>? experiences,
    bool? profileCreated,
    String? message,
    bool clearFailure = false,
  }) {
    return DoctorProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      failure: clearFailure ? null : (failure ?? this.failure),
      qualifications: qualifications ?? this.qualifications,
      registrations: registrations ?? this.registrations,
      experiences: experiences ?? this.experiences,
      profileCreated: profileCreated ?? this.profileCreated,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    failure,
    qualifications,
    registrations,
    experiences,
    profileCreated,
    message,
  ];
}
