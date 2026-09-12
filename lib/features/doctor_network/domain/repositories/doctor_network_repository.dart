import '../entities/doctor_search_query.dart';
import '../entities/doctor_search_result.dart';
import '../entities/paginated_result.dart';
import '../entities/public_doctor_profile.dart';

/// Repository for the doctor professional network (discovery).
abstract class DoctorNetworkRepository {
  /// Searches discoverable doctors with [query] and returns one page of
  /// results plus pagination metadata.
  Future<PaginatedResult<DoctorSearchResult>> searchDoctors(
    DoctorSearchQuery query,
  );

  /// Fetches a doctor's public profile by [doctorId].
  Future<PublicDoctorProfile> getDoctorProfile(String doctorId);
}
