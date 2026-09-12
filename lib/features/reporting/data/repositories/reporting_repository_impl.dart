import '../../domain/entities/reporting_entity.dart';
import '../../domain/repositories/reporting_repository.dart';
import '../datasources/reporting_remote_data_source.dart';

class ReportingRepositoryImpl implements ReportingRepository {
  final ReportingRemoteDataSource remoteDataSource;

  ReportingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReportingEntity?> getReportingData() async {
    // TODO: Implement repository logic
    return null;
  }
}
