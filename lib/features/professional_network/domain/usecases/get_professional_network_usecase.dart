import '../entities/professional_network_entity.dart';
import '../repositories/professional_network_repository.dart';

class GetProfessionalNetworkUseCase {
  final ProfessionalNetworkRepository repository;

  GetProfessionalNetworkUseCase(this.repository);

  Future<ProfessionalNetworkEntity?> call() async {
    return await repository.getProfessionalNetworkData();
  }
}
