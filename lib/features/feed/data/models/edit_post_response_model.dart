import 'package:equatable/equatable.dart';

/// Wire-format model for PATCH /api/v1/feed/posts/{id}/ response.
class EditPostResponseModel extends Equatable {
  final bool success;
  final String content;
  final String? image;

  const EditPostResponseModel({
    required this.success,
    required this.content,
    this.image,
  });

  factory EditPostResponseModel.fromJson(Map<String, dynamic> json) {
    return EditPostResponseModel(
      success: json['success'] as bool? ?? false,
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  @override
  List<Object?> get props => [success, content, image];
}
