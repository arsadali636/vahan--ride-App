import '../../domain/entities/search_entity.dart';

class SearchModel extends SearchEntity {
  const SearchModel({required super.id});

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
