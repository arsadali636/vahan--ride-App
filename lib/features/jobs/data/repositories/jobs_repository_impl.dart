import '../../domain/entities/jobs_entity.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_data_source.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<JobsEntity?> getJobsData() async {
    // TODO: Implement repository logic
    return null;
  }
}
