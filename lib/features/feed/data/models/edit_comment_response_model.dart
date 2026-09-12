import 'package:equatable/equatable.dart';

/// Response model for PATCH /api/v1/feed/comments/{id}/.
class EditCommentResponseModel extends Equatable {
  final bool success;
  final String content;

  const EditCommentResponseModel({
    required this.success,
    required this.content,
  });

  factory EditCommentResponseModel.fromJson(Map<String, dynamic> json) {
    return EditCommentResponseModel(
      success: json['success'] as bool? ?? false,
      content: json['content'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [success, content];
}
