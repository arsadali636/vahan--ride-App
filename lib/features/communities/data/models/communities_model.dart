import '../../domain/entities/communities_entity.dart';

class CommunitiesModel extends CommunitiesEntity {
  const CommunitiesModel({required super.id});

  factory CommunitiesModel.fromJson(Map<String, dynamic> json) {
    return CommunitiesModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
