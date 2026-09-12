import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_remote_data_source.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityRemoteDataSource remoteDataSource;

  AvailabilityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AvailabilityEntity?> getAvailabilityData() async {
    // TODO: Implement repository logic
    return null;
  }
}
