import '../entities/privacy_entity.dart';
import '../repositories/privacy_repository.dart';

class GetPrivacyUseCase {
  final PrivacyRepository repository;

  GetPrivacyUseCase(this.repository);

  Future<PrivacyEntity?> call() async {
    return await repository.getPrivacyData();
  }
}
