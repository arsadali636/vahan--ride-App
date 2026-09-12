import '../../domain/entities/messaging_entity.dart';

class MessagingModel extends MessagingEntity {
  const MessagingModel({required super.id});

  factory MessagingModel.fromJson(Map<String, dynamic> json) {
    return MessagingModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
