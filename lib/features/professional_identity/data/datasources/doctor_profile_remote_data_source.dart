import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/doctor_experience_model.dart';
import '../models/doctor_profile_create_model.dart';
import '../models/doctor_profile_response_model.dart';
import '../models/doctor_profile_update_model.dart';
import '../models/doctor_qualification_model.dart';
import '../models/doctor_registration_model.dart';

/// Remote data source for doctor profile endpoints.
///
/// All calls are authenticated (`requiresAuth` defaults to `true`).
abstract class DoctorProfileRemoteDataSource {
  /// Creates the caller's doctor profile.
  ///
  /// Path: `POST /api/v1/doctors/profile/` (authenticated).
  Future<DoctorProfileResponseModel> create(DoctorProfileCreateModel request);

  /// Reads the caller's doctor profile.
  ///
  /// Path: `GET /api/v1/doctors/profile/me/` (authenticated).
  Future<DoctorProfileResponseModel> getMyProfile();

  /// Partially updates the caller's doctor profile.
  ///
  /// Path: `PATCH /api/v1/doctors/profile/me/` (authenticated).
  Future<DoctorProfileResponseModel> update(DoctorProfileUpdateModel request);

  /// Reads a public doctor profile by id.
  ///
  /// Path: `GET /api/v1/doctors/profile/{doctor_id}/`.
  Future<DoctorProfileResponseModel> getDoctorProfileById(String doctorId);

  /// Uploads a profile photo.
  ///
  /// Path: `POST /api/v1/doctors/profile/me/photo/` (multipart field `file`).
  /// Returns the `photo_file_id` when the backend echoes it; `null` otherwise.
  Future<String?> uploadPhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  });

  /// Lists the caller's qualifications.
  ///
  /// Path: `GET /api/v1/doctors/profile/me/qualifications/`.
  Future<List<DoctorQualificationModel>> listQualifications();

  /// Adds a qualification.
  ///
  /// Path: `POST /api/v1/doctors/profile/me/qualifications/`.
  Future<DoctorQualificationModel> addQualification(
    DoctorQualificationModel request,
  );

  /// Deletes a qualification.
  ///
  /// Path: `DELETE /api/v1/doctors/profile/me/qualifications/{id}/`.
  Future<void> deleteQualification(String qualificationId);

  /// Lists the caller's registrations.
  ///
  /// Path: `GET /api/v1/doctors/profile/me/registrations/`.
  Future<List<DoctorRegistrationModel>> listRegistrations();

  /// Adds a registration.
  ///
  /// Path: `POST /api/v1/doctors/profile/me/registrations/`.
  Future<DoctorRegistrationModel> addRegistration(
    DoctorRegistrationModel request,
  );

  /// Lists the caller's work-experience entries.
  ///
  /// Path: `GET /api/v1/doctors/profile/me/experiences/`.
  Future<List<DoctorExperienceModel>> listExperiences();

  /// Adds a work-experience entry.
  ///
  /// Path: `POST /api/v1/doctors/profile/me/experiences/`.
  Future<DoctorExperienceModel> addExperience(DoctorExperienceModel request);

  /// Deletes a work-experience entry.
  ///
  /// Path: `DELETE /api/v1/doctors/profile/me/experiences/{id}/` (204).
  Future<void> deleteExperience(String experienceId);
}

class DoctorProfileRemoteDataSourceImpl implements DoctorProfileRemoteDataSource {
  DoctorProfileRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<DoctorProfileResponseModel> create(
    DoctorProfileCreateModel request,
  ) async {
    final data = await apiClient.post(
      ApiEndpoints.doctorProfileCreate,
      data: request.toJson(),
    );
    return DoctorProfileResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<DoctorProfileResponseModel> getMyProfile() async {
    final data = await apiClient.get(ApiEndpoints.doctorProfileMe);
    return DoctorProfileResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<DoctorProfileResponseModel> update(
    DoctorProfileUpdateModel request,
  ) async {
    final data = await apiClient.patch(
      ApiEndpoints.doctorProfileMe,
      data: request.toJson(),
    );
    return DoctorProfileResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<DoctorProfileResponseModel> getDoctorProfileById(String doctorId) async {
    final data = await apiClient.get(ApiEndpoints.doctorProfileById(doctorId));
    return DoctorProfileResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<String?> uploadPhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(contentType),
      ),
    });
    final data = await apiClient.post(
      ApiEndpoints.doctorPhotoUpload,
      data: formData,
    );
    if (data is Map) {
      return data['photo_file_id'] as String?;
    }
    return null;
  }

  @override
  Future<List<DoctorQualificationModel>> listQualifications() async {
    final data = await apiClient.get(ApiEndpoints.doctorQualifications);
    return (data as List? ?? const [])
        .map((e) => DoctorQualificationModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  @override
  Future<DoctorQualificationModel> addQualification(
    DoctorQualificationModel request,
  ) async {
    final data = await apiClient.post(
      ApiEndpoints.doctorQualifications,
      data: request.toJson(),
    );
    return DoctorQualificationModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<void> deleteQualification(String qualificationId) async {
    await apiClient.delete(
      ApiEndpoints.doctorQualificationById(qualificationId),
    );
  }

  @override
  Future<List<DoctorRegistrationModel>> listRegistrations() async {
    final data = await apiClient.get(ApiEndpoints.doctorRegistrations);
    return (data as List? ?? const [])
        .map((e) => DoctorRegistrationModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  @override
  Future<DoctorRegistrationModel> addRegistration(
    DoctorRegistrationModel request,
  ) async {
    final data = await apiClient.post(
      ApiEndpoints.doctorRegistrations,
      data: request.toJson(),
    );
    return DoctorRegistrationModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<List<DoctorExperienceModel>> listExperiences() async {
    final data = await apiClient.get(ApiEndpoints.doctorExperiences);
    return (data as List? ?? const [])
        .map((e) => DoctorExperienceModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ))
        .toList();
  }

  @override
  Future<DoctorExperienceModel> addExperience(
    DoctorExperienceModel request,
  ) async {
    final data = await apiClient.post(
      ApiEndpoints.doctorExperiences,
      data: request.toJson(),
    );
    return DoctorExperienceModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    await apiClient.delete(
      ApiEndpoints.doctorExperienceById(experienceId),
    );
  }
}
