import '../../domain/entities/professional_network_entity.dart';
import '../../domain/repositories/professional_network_repository.dart';
import '../datasources/professional_network_remote_data_source.dart';

class ProfessionalNetworkRepositoryImpl implements ProfessionalNetworkRepository {
  final ProfessionalNetworkRemoteDataSource remoteDataSource;

  ProfessionalNetworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfessionalNetworkEntity?> getProfessionalNetworkData() async {
    // TODO: Implement repository logic
    return null;
  }
}
