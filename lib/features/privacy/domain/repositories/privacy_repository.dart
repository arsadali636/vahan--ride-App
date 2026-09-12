import '../entities/privacy_entity.dart';

abstract class PrivacyRepository {
  Future<PrivacyEntity?> getPrivacyData();
}
