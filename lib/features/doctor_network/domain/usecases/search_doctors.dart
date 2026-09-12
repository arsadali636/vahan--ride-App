import '../entities/doctor_search_query.dart';
import '../entities/doctor_search_result.dart';
import '../entities/paginated_result.dart';
import '../repositories/doctor_network_repository.dart';

/// Searches discoverable doctors with the given [DoctorSearchQuery].
class SearchDoctors {
  final DoctorNetworkRepository repository;

  SearchDoctors(this.repository);

  Future<PaginatedResult<DoctorSearchResult>> call(DoctorSearchQuery query) {
    return repository.searchDoctors(query);
  }
}
