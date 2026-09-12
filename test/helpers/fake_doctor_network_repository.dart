import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_query.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/paginated_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/public_doctor_profile.dart';
import 'package:doc_connect_app/features/doctor_network/domain/repositories/doctor_network_repository.dart';

/// Configurable in-memory [DoctorNetworkRepository] for bloc and widget tests.
///
/// [searchPages] is a queue consumed one page at a time; each entry is
/// returned for the matching request order. [searchFailure] / [profileFailure]
/// throw instead of returning. [searchDelay] lets tests observe the transient
/// loading state under fake-async pumps.
class FakeDoctorNetworkRepository implements DoctorNetworkRepository {
  List<PaginatedResult<DoctorSearchResult>> searchPages;
  Failure? searchFailure;
  Failure? profileFailure;
  PublicDoctorProfile? profile;
  Duration? searchDelay;
  Duration? profileDelay;

  int searchCalls = 0;
  int profileCalls = 0;
  DoctorSearchQuery? lastQuery;
  String? lastDoctorId;

  FakeDoctorNetworkRepository({List<PaginatedResult<DoctorSearchResult>>? searchPages})
      : searchPages = searchPages ?? [];

  @override
  Future<PaginatedResult<DoctorSearchResult>> searchDoctors(
    DoctorSearchQuery query,
  ) async {
    if (searchDelay != null) await Future<void>.delayed(searchDelay!);
    searchCalls++;
    lastQuery = query;
    if (searchFailure != null) throw searchFailure!;
    final index = query.page - 1;
    if (index < 0 || index >= searchPages.length) {
      return PaginatedResult(
        items: const [],
        total: 0,
        page: query.page,
        pageSize: query.pageSize,
      );
    }
    return searchPages[index];
  }

  @override
  Future<PublicDoctorProfile> getDoctorProfile(String doctorId) async {
    if (profileDelay != null) await Future<void>.delayed(profileDelay!);
    profileCalls++;
    lastDoctorId = doctorId;
    if (profileFailure != null) throw profileFailure!;
    return profile ??
        PublicDoctorProfile(
          id: doctorId,
          fullName: 'Doctor',
          firstName: 'Doctor',
          lastName: 'One',
        );
  }
}
