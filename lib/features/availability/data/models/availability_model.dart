import '../../domain/entities/availability_entity.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({required super.id});

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
