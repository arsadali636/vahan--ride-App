import '../entities/applications_entity.dart';
import '../repositories/applications_repository.dart';

class GetApplicationsUseCase {
  final ApplicationsRepository repository;

  GetApplicationsUseCase(this.repository);

  Future<ApplicationsEntity?> call() async {
    return await repository.getApplicationsData();
  }
}
