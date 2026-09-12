import '../entities/messaging_entity.dart';

abstract class MessagingRepository {
  Future<MessagingEntity?> getMessagingData();
}
