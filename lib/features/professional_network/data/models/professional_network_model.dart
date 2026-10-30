import '../../domain/entities/professional_network_entity.dart';

class ProfessionalNetworkModel extends ProfessionalNetworkEntity {
  const ProfessionalNetworkModel({required super.id});

  factory ProfessionalNetworkModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalNetworkModel(id: json['id'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
