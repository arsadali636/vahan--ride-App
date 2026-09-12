import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

enum PostComposerStatus { initial, submitting, success, failure }

class PostComposerState extends Equatable {
  final PostComposerStatus status;
  final String postType;
  final bool isAnonymous;
  final String? imagePath;
  final Failure? error;

  const PostComposerState({
    this.status = PostComposerStatus.initial,
    this.postType = 'UPDATE',
    this.isAnonymous = false,
    this.imagePath,
    this.error,
  });

  bool get isCaseType => postType == 'CASE';

  PostComposerState copyWith({
    PostComposerStatus? status,
    String? postType,
    bool? isAnonymous,
    String? imagePath,
    bool clearImage = false,
    Failure? error,
    bool clearError = false,
  }) {
    return PostComposerState(
      status: status ?? this.status,
      postType: postType ?? this.postType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, postType, isAnonymous, imagePath, error];
}
