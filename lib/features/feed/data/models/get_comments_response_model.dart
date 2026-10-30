import 'package:equatable/equatable.dart';

import '../../domain/entities/comment.dart';
import 'comment_model.dart';

/// Response model for GET /api/v1/feed/posts/{id}/comments/.
class GetCommentsResponseModel extends Equatable {
  final List<CommentModel> comments;

  const GetCommentsResponseModel({required this.comments});

  factory GetCommentsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetCommentsResponseModel(
      comments: (json['comments'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => CommentModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  List<Comment> toEntities() {
    return comments.map((e) => e.toEntity()).toList();
  }

  @override
  List<Object?> get props => [comments];
}
