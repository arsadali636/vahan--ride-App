import '../entities/availability_entity.dart';
import '../repositories/availability_repository.dart';

class GetAvailabilityUseCase {
  final AvailabilityRepository repository;

  GetAvailabilityUseCase(this.repository);

  Future<AvailabilityEntity?> call() async {
    return await repository.getAvailabilityData();
  }
}
