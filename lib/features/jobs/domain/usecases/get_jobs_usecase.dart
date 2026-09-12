import '../entities/jobs_entity.dart';
import '../repositories/jobs_repository.dart';

class GetJobsUseCase {
  final JobsRepository repository;

  GetJobsUseCase(this.repository);

  Future<JobsEntity?> call() async {
    return await repository.getJobsData();
  }
}
