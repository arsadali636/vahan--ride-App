import '../entities/applications_entity.dart';

abstract class ApplicationsRepository {
  Future<ApplicationsEntity?> getApplicationsData();
}
