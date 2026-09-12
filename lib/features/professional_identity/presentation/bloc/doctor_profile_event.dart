import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_experience_draft.dart';
import '../../domain/entities/doctor_photo.dart';
import '../../domain/entities/doctor_profile_draft.dart';
import '../../domain/entities/doctor_qualification_draft.dart';
import '../../domain/entities/doctor_registration_draft.dart';

/// UI intents for the doctor professional profile.
///
/// Every event carries the full snapshot of the data it needs — the bloc does
/// not read form state from widgets.
abstract class DoctorProfileEvent extends Equatable {
  const DoctorProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the caller's profile (and its sub-resources) from the backend.
class DoctorProfileLoadRequested extends DoctorProfileEvent {
  const DoctorProfileLoadRequested();
}

/// Creates the caller's professional profile from [draft].
class DoctorProfileCreateRequested extends DoctorProfileEvent {
  final DoctorProfileDraft draft;

  const DoctorProfileCreateRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Partially updates the caller's professional profile from [draft].
class DoctorProfileUpdateRequested extends DoctorProfileEvent {
  final DoctorProfileDraft draft;

  const DoctorProfileUpdateRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Uploads [photo] as the caller's profile photo.
class DoctorProfilePhotoUploadRequested extends DoctorProfileEvent {
  final DoctorPhoto photo;

  const DoctorProfilePhotoUploadRequested(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Re-fetches the profile and all sub-resources (pull-to-refresh).
class DoctorProfileRefreshRequested extends DoctorProfileEvent {
  const DoctorProfileRefreshRequested();
}

/// Adds a qualification.
class AddQualificationRequested extends DoctorProfileEvent {
  final DoctorQualificationDraft draft;

  const AddQualificationRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Deletes a qualification by id.
class DeleteQualificationRequested extends DoctorProfileEvent {
  final String qualificationId;

  const DeleteQualificationRequested(this.qualificationId);

  @override
  List<Object?> get props => [qualificationId];
}

/// Adds a registration.
class AddRegistrationRequested extends DoctorProfileEvent {
  final DoctorRegistrationDraft draft;

  const AddRegistrationRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Adds a work-experience entry.
class AddExperienceRequested extends DoctorProfileEvent {
  final DoctorExperienceDraft draft;

  const AddExperienceRequested(this.draft);

  @override
  List<Object?> get props => [draft];
}

/// Deletes a work-experience entry by id.
class DeleteExperienceRequested extends DoctorProfileEvent {
  final String experienceId;

  const DeleteExperienceRequested(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}
