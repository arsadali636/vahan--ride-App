import '../entities/jobs_entity.dart';

abstract class JobsRepository {
  Future<JobsEntity?> getJobsData();
}
