import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/doctor_experience.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_qualification.dart';
import '../../domain/entities/doctor_registration.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_remote_data_source.dart';
import '../models/doctor_experience_model.dart';
import '../models/doctor_profile_create_model.dart';
import '../models/doctor_profile_update_model.dart';
import '../models/doctor_qualification_model.dart';
import '../models/doctor_registration_model.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  DoctorProfileRepositoryImpl({required this.remoteDataSource});

  final DoctorProfileRemoteDataSource remoteDataSource;

  @override
  Future<DoctorProfile> createProfile({
    required String firstName,
    required String lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
  }) async {
    try {
      final response = await remoteDataSource.create(
        DoctorProfileCreateModel(
          firstName: firstName,
          lastName: lastName,
          headline: headline,
          about: about,
          primarySpecializationId: primarySpecializationId,
          clinicalInterests: clinicalInterests,
          professionalLocation: professionalLocation,
          experienceYears: experienceYears,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorProfile> getMyProfile() async {
    try {
      final response = await remoteDataSource.getMyProfile();
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorProfile> getDoctorProfileById(String doctorId) async {
    try {
      final response = await remoteDataSource.getDoctorProfileById(doctorId);
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
    bool? openToOpportunities,
  }) async {
    try {
      final response = await remoteDataSource.update(
        DoctorProfileUpdateModel(
          firstName: firstName,
          lastName: lastName,
          headline: headline,
          about: about,
          primarySpecializationId: primarySpecializationId,
          clinicalInterests: clinicalInterests,
          professionalLocation: professionalLocation,
          experienceYears: experienceYears,
          openToOpportunities: openToOpportunities,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<String?> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    try {
      return await remoteDataSource.uploadPhoto(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<List<DoctorQualification>> listQualifications() async {
    try {
      final response = await remoteDataSource.listQualifications();
      return response.map((e) => e.toEntity()).toList();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorQualification> addQualification({
    required String degree,
    required String institution,
    required int year,
    String? specialization,
  }) async {
    try {
      final response = await remoteDataSource.addQualification(
        DoctorQualificationModel(
          degree: degree,
          institution: institution,
          year: year,
          specialization: specialization,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<void> deleteQualification(String qualificationId) async {
    try {
      await remoteDataSource.deleteQualification(qualificationId);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<List<DoctorRegistration>> listRegistrations() async {
    try {
      final response = await remoteDataSource.listRegistrations();
      return response.map((e) => e.toEntity()).toList();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorRegistration> addRegistration({
    required String councilId,
    required String registrationNumber,
    required int registrationYear,
    bool isPrimary = false,
  }) async {
    try {
      final response = await remoteDataSource.addRegistration(
        DoctorRegistrationModel(
          councilId: councilId,
          registrationNumber: registrationNumber,
          registrationYear: registrationYear,
          isPrimary: isPrimary,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<List<DoctorExperience>> listExperiences() async {
    try {
      final response = await remoteDataSource.listExperiences();
      return response.map((e) => e.toEntity()).toList();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<DoctorExperience> addExperience({
    required String role,
    required String hospitalName,
    String? location,
    String? startDate,
    String? endDate,
    bool isCurrent = false,
    String? description,
  }) async {
    try {
      final response = await remoteDataSource.addExperience(
        DoctorExperienceModel(
          role: role,
          hospitalName: hospitalName,
          location: location,
          startDate: startDate,
          endDate: endDate,
          isCurrent: isCurrent,
          description: description,
        ),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    try {
      await remoteDataSource.deleteExperience(experienceId);
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }
}
