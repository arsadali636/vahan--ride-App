import '../entities/notifications_entity.dart';

abstract class NotificationsRepository {
  Future<NotificationsEntity?> getNotificationsData();
}
