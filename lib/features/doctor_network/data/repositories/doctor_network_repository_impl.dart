import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/doctor_search_query.dart';
import '../../domain/entities/doctor_search_result.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/public_doctor_profile.dart';
import '../../domain/repositories/doctor_network_repository.dart';
import '../datasources/doctor_network_remote_data_source.dart';
import '../models/doctor_search_query_model.dart';

class DoctorNetworkRepositoryImpl implements DoctorNetworkRepository {
  DoctorNetworkRepositoryImpl({required this.remoteDataSource});

  final DoctorNetworkRemoteDataSource remoteDataSource;

  @override
  Future<PaginatedResult<DoctorSearchResult>> searchDoctors(
    DoctorSearchQuery query,
  ) async {
    try {
      final response = await remoteDataSource.searchDoctors(
        DoctorSearchQueryModel.fromDomain(query),
      );
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }

  @override
  Future<PublicDoctorProfile> getDoctorProfile(String doctorId) async {
    try {
      final response = await remoteDataSource.getDoctorProfile(doctorId);
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }
}
