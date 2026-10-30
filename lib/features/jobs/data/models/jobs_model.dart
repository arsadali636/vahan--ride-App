import '../../domain/entities/jobs_entity.dart';

class JobsModel extends JobsEntity {
  const JobsModel({required super.id});

  factory JobsModel.fromJson(Map<String, dynamic> json) {
    return JobsModel(id: json['id'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
