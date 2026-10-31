import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

enum PostComposerStatus { initial, submitting, success, failure }

class PostComposerState extends Equatable {
  final PostComposerStatus status;
  final String postType;
  final bool isAnonymous;
  final String? imagePath;
  final String? imageName;
  final List<int>? imageBytes;
  final Failure? error;

  const PostComposerState({
    this.status = PostComposerStatus.initial,
    this.postType = 'UPDATE',
    this.isAnonymous = false,
    this.imagePath,
    this.imageName,
    this.imageBytes,
    this.error,
  });

  bool get isCaseType => postType == 'CASE';
  bool get hasImage =>
      (imageBytes != null && imageBytes!.isNotEmpty) ||
      (imagePath != null && imagePath!.isNotEmpty);

  PostComposerState copyWith({
    PostComposerStatus? status,
    String? postType,
    bool? isAnonymous,
    String? imagePath,
    String? imageName,
    List<int>? imageBytes,
    bool clearImage = false,
    Failure? error,
    bool clearError = false,
  }) {
    return PostComposerState(
      status: status ?? this.status,
      postType: postType ?? this.postType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      imageName: clearImage ? null : (imageName ?? this.imageName),
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    postType,
    isAnonymous,
    imagePath,
    imageName,
    imageBytes,
    error,
  ];
}
