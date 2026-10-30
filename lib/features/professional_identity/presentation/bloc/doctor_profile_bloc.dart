// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/session_service.dart';
import '../../domain/entities/doctor_experience.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_qualification.dart';
import '../../domain/entities/doctor_registration.dart';
import '../../domain/usecases/add_experience_usecase.dart';
import '../../domain/usecases/add_qualification_usecase.dart';
import '../../domain/usecases/add_registration_usecase.dart';
import '../../domain/usecases/create_doctor_profile_usecase.dart';
import '../../domain/usecases/delete_experience_usecase.dart';
import '../../domain/usecases/delete_qualification_usecase.dart';
import '../../domain/usecases/get_doctor_profile_usecase.dart';
import '../../domain/usecases/list_experiences_usecase.dart';
import '../../domain/usecases/list_qualifications_usecase.dart';
import '../../domain/usecases/list_registrations_usecase.dart';
import '../../domain/usecases/update_doctor_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import 'doctor_profile_event.dart';
import 'doctor_profile_state.dart';

/// Orchestrates the doctor professional profile screen.
///
/// The UI sends [DoctorProfileEvent]s and renders [DoctorProfileState]. Every
/// read/write goes through a usecase; the bloc never touches Dio or storage
/// directly. On a successful profile creation it records `profile_created`
/// through [SessionService] (never SecureStorage directly).
class DoctorProfileBloc extends Bloc<DoctorProfileEvent, DoctorProfileState> {
  DoctorProfileBloc({
    required SessionService sessionService,
    required GetDoctorProfile getDoctorProfile,
    required CreateDoctorProfile createDoctorProfile,
    required UpdateDoctorProfile updateDoctorProfile,
    required UploadProfilePhoto uploadProfilePhoto,
    required ListQualifications listQualifications,
    required AddQualification addQualification,
    required DeleteQualification deleteQualification,
    required ListRegistrations listRegistrations,
    required AddRegistration addRegistration,
    required ListExperiences listExperiences,
    required AddExperience addExperience,
    required DeleteExperience deleteExperience,
  }) : _sessionService = sessionService,
       _getDoctorProfile = getDoctorProfile,
       _createDoctorProfile = createDoctorProfile,
       _updateDoctorProfile = updateDoctorProfile,
       _uploadProfilePhoto = uploadProfilePhoto,
       _listQualifications = listQualifications,
       _addQualification = addQualification,
       _deleteQualification = deleteQualification,
       _listRegistrations = listRegistrations,
       _addRegistration = addRegistration,
       _listExperiences = listExperiences,
       _addExperience = addExperience,
       _deleteExperience = deleteExperience,
       super(const DoctorProfileState()) {
    on<DoctorProfileLoadRequested>(_onLoadRequested);
    on<DoctorProfileRefreshRequested>(_onRefreshRequested);
    on<DoctorProfileCreateRequested>(_onCreateRequested);
    on<DoctorProfileUpdateRequested>(_onUpdateRequested);
    on<DoctorProfilePhotoUploadRequested>(_onPhotoUploadRequested);
    on<AddQualificationRequested>(_onAddQualificationRequested);
    on<DeleteQualificationRequested>(_onDeleteQualificationRequested);
    on<AddRegistrationRequested>(_onAddRegistrationRequested);
    on<AddExperienceRequested>(_onAddExperienceRequested);
    on<DeleteExperienceRequested>(_onDeleteExperienceRequested);
  }

  final SessionService _sessionService;
  final GetDoctorProfile _getDoctorProfile;
  final CreateDoctorProfile _createDoctorProfile;
  final UpdateDoctorProfile _updateDoctorProfile;
  final UploadProfilePhoto _uploadProfilePhoto;
  final ListQualifications _listQualifications;
  final AddQualification _addQualification;
  final DeleteQualification _deleteQualification;
  final ListRegistrations _listRegistrations;
  final AddRegistration _addRegistration;
  final ListExperiences _listExperiences;
  final AddExperience _addExperience;
  final DeleteExperience _deleteExperience;

  Future<void> _onLoadRequested(
    DoctorProfileLoadRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    final profileCreated = await _sessionService.getProfileCreated();
    emit(
      state.copyWith(
        profileCreated: profileCreated,
        status: DoctorProfileStatus.loading,
        clearFailure: true,
      ),
    );
    await _loadProfileAndResources(emit);
  }

  Future<void> _onRefreshRequested(
    DoctorProfileRefreshRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DoctorProfileStatus.refreshing,
        clearFailure: true,
      ),
    );
    await _loadProfileAndResources(emit);
  }

  /// Loads the profile and every sub-resource, preserving existing data on
  /// failure so the screen can render stale content with an error banner.
  Future<void> _loadProfileAndResources(
    Emitter<DoctorProfileState> emit,
  ) async {
    DoctorProfile? profile;
    try {
      profile = await _getDoctorProfile();
    } on NotFoundFailure {
      // No profile yet — profileCreated=false keeps the completion flow active.
      emit(
        state.copyWith(
          profile: null,
          status: DoctorProfileStatus.loaded,
          message: null,
        ),
      );
      return;
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
      return;
    }

    final qualifications = await _safeGetQualifications();
    final registrations = await _safeGetRegistrations();
    final experiences = await _safeGetExperiences();

    emit(
      state.copyWith(
        profile: profile,
        status: DoctorProfileStatus.loaded,
        qualifications: qualifications,
        registrations: registrations,
        experiences: experiences,
        message: null,
      ),
    );
  }

  Future<void> _onCreateRequested(
    DoctorProfileCreateRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    emit(
      state.copyWith(status: DoctorProfileStatus.creating, clearFailure: true),
    );
    try {
      final profile = await _createDoctorProfile(
        firstName: event.draft.firstName,
        lastName: event.draft.lastName,
        headline: event.draft.headline,
        about: event.draft.about,
        primarySpecializationId: event.draft.primarySpecializationId,
        clinicalInterests: event.draft.clinicalInterests,
        professionalLocation: event.draft.location,
        experienceYears: event.draft.experienceYears,
      );
      await _sessionService.saveProfileCreated(true);
      final qualifications = await _safeGetQualifications();
      final registrations = await _safeGetRegistrations();
      final experiences = await _safeGetExperiences();
      emit(
        state.copyWith(
          profile: profile,
          profileCreated: true,
          status: DoctorProfileStatus.success,
          qualifications: qualifications,
          registrations: registrations,
          experiences: experiences,
          message: 'Profile created',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    DoctorProfileUpdateRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    emit(
      state.copyWith(status: DoctorProfileStatus.updating, clearFailure: true),
    );
    try {
      final profile = await _updateDoctorProfile(
        firstName: event.draft.firstName,
        lastName: event.draft.lastName,
        headline: event.draft.headline,
        about: event.draft.about,
        primarySpecializationId: event.draft.primarySpecializationId,
        clinicalInterests: event.draft.clinicalInterests,
        professionalLocation: event.draft.location,
        experienceYears: event.draft.experienceYears,
        openToOpportunities: event.draft.openToOpportunities,
      );
      emit(
        state.copyWith(
          profile: profile,
          status: DoctorProfileStatus.success,
          message: 'Profile updated',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onPhotoUploadRequested(
    DoctorProfilePhotoUploadRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DoctorProfileStatus.uploadingPhoto,
        clearFailure: true,
      ),
    );
    try {
      await _uploadProfilePhoto(
        bytes: event.photo.bytes,
        filename: event.photo.filename,
        contentType: event.photo.contentType,
      );
      // Refresh so the photo file id reflects on the profile.
      final profile = await _getDoctorProfile();
      emit(
        state.copyWith(
          profile: profile,
          status: DoctorProfileStatus.success,
          message: 'Photo uploaded',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onAddQualificationRequested(
    AddQualificationRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      await _addQualification(
        degree: event.draft.degree,
        institution: event.draft.institution,
        year: event.draft.year,
        specialization: event.draft.specialization,
      );
      final qualifications = await _safeGetQualifications();
      emit(
        state.copyWith(
          qualifications: qualifications,
          status: DoctorProfileStatus.success,
          message: 'Qualification added',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onDeleteQualificationRequested(
    DeleteQualificationRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      await _deleteQualification(event.qualificationId);
      final qualifications = await _safeGetQualifications();
      emit(
        state.copyWith(
          qualifications: qualifications,
          status: DoctorProfileStatus.success,
          message: 'Qualification removed',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onAddRegistrationRequested(
    AddRegistrationRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      await _addRegistration(
        councilId: event.draft.councilId,
        registrationNumber: event.draft.registrationNumber,
        registrationYear: event.draft.registrationYear,
        isPrimary: event.draft.isPrimary,
      );
      final registrations = await _safeGetRegistrations();
      emit(
        state.copyWith(
          registrations: registrations,
          status: DoctorProfileStatus.success,
          message: 'Registration added',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onAddExperienceRequested(
    AddExperienceRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      await _addExperience(
        role: event.draft.role,
        hospitalName: event.draft.hospitalName,
        location: event.draft.location,
        startDate: event.draft.startDate,
        endDate: event.draft.endDate,
        isCurrent: event.draft.isCurrent,
        description: event.draft.description,
      );
      final experiences = await _safeGetExperiences();
      emit(
        state.copyWith(
          experiences: experiences,
          status: DoctorProfileStatus.success,
          message: 'Experience added',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  Future<void> _onDeleteExperienceRequested(
    DeleteExperienceRequested event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      await _deleteExperience(event.experienceId);
      final experiences = await _safeGetExperiences();
      emit(
        state.copyWith(
          experiences: experiences,
          status: DoctorProfileStatus.success,
          message: 'Experience removed',
          clearFailure: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: DoctorProfileStatus.failure,
          failure: e,
          message: null,
        ),
      );
    }
  }

  /// Sub-resource reads degrade to empty lists (a failure on one resource must
  /// not blank the whole screen).
  Future<List<DoctorQualification>> _safeGetQualifications() async {
    try {
      return await _listQualifications();
    } on Failure {
      return const [];
    }
  }

  Future<List<DoctorRegistration>> _safeGetRegistrations() async {
    try {
      return await _listRegistrations();
    } on Failure {
      return const [];
    }
  }

  Future<List<DoctorExperience>> _safeGetExperiences() async {
    try {
      return await _listExperiences();
    } on Failure {
      return const [];
    }
  }
}
