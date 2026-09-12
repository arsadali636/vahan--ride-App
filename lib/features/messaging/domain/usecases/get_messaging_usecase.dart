import '../entities/messaging_entity.dart';
import '../repositories/messaging_repository.dart';

class GetMessagingUseCase {
  final MessagingRepository repository;

  GetMessagingUseCase(this.repository);

  Future<MessagingEntity?> call() async {
    return await repository.getMessagingData();
  }
}
