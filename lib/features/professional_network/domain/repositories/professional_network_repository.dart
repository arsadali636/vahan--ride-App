import '../entities/professional_network_entity.dart';

abstract class ProfessionalNetworkRepository {
  Future<ProfessionalNetworkEntity?> getProfessionalNetworkData();
}
