import '../../domain/entities/reporting_entity.dart';

class ReportingModel extends ReportingEntity {
  const ReportingModel({required super.id});

  factory ReportingModel.fromJson(Map<String, dynamic> json) {
    return ReportingModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
