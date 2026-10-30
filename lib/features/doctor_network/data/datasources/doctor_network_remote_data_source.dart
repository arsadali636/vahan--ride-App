import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/doctor_search_query_model.dart';
import '../models/doctor_search_response_model.dart';
import '../models/public_doctor_profile_model.dart';

/// Remote data source for doctor discovery endpoints.
///
/// All calls are authenticated (the OpenAPI contract marks both operations
/// with `HTTPBearer`, so [ApiClient.requiresAuth] keeps its default of `true`).
abstract class DoctorNetworkRemoteDataSource {
  /// Searches discoverable doctors.
  ///
  /// Path: `GET /api/v1/doctors/search/` (authenticated).
  Future<DoctorSearchResponseModel> searchDoctors(DoctorSearchQueryModel query);

  /// Fetches a doctor's public profile.
  ///
  /// Path: `GET /api/v1/doctors/profile/{doctor_id}/` (authenticated).
  Future<PublicDoctorProfileModel> getDoctorProfile(String doctorId);
}

class DoctorNetworkRemoteDataSourceImpl
    implements DoctorNetworkRemoteDataSource {
  DoctorNetworkRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<DoctorSearchResponseModel> searchDoctors(
    DoctorSearchQueryModel query,
  ) async {
    final data = await apiClient.get(
      ApiEndpoints.doctorSearch,
      queryParameters: query.toQueryParameters(),
    );
    return DoctorSearchResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<PublicDoctorProfileModel> getDoctorProfile(String doctorId) async {
    final data = await apiClient.get(ApiEndpoints.doctorProfileById(doctorId));
    return PublicDoctorProfileModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }
}
