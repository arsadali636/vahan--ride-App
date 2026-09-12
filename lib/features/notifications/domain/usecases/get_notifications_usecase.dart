import '../entities/notifications_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<NotificationsEntity?> call() async {
    return await repository.getNotificationsData();
  }
}
