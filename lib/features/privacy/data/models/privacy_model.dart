import '../../domain/entities/privacy_entity.dart';

class PrivacyModel extends PrivacyEntity {
  const PrivacyModel({required super.id});

  factory PrivacyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
