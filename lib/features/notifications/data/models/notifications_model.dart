import '../../domain/entities/notifications_entity.dart';

class NotificationsModel extends NotificationsEntity {
  const NotificationsModel({required super.id});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
