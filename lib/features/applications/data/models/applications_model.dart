import '../../domain/entities/applications_entity.dart';

class ApplicationsModel extends ApplicationsEntity {
  const ApplicationsModel({required super.id});

  factory ApplicationsModel.fromJson(Map<String, dynamic> json) {
    return ApplicationsModel(id: json['id'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
