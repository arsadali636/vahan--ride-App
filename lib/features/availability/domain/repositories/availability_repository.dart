import '../entities/availability_entity.dart';

abstract class AvailabilityRepository {
  Future<AvailabilityEntity?> getAvailabilityData();
}
