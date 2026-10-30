import 'package:equatable/equatable.dart';

/// Wire-format model for the create post success response.
class CreatePostResponseModel extends Equatable {
  final bool success;
  final String postId;
  final String author;
  final String postType;
  final String content;
  final String? image;
  final String createdAt;

  const CreatePostResponseModel({
    required this.success,
    required this.postId,
    required this.author,
    required this.postType,
    required this.content,
    this.image,
    required this.createdAt,
  });

  factory CreatePostResponseModel.fromJson(Map<String, dynamic> json) {
    return CreatePostResponseModel(
      success: json['success'] as bool? ?? false,
      postId: json['post_id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      postType: json['post_type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    success,
    postId,
    author,
    postType,
    content,
    image,
    createdAt,
  ];
}
