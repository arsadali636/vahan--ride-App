import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

class FeedPostLiked extends FeedEvent {
  final String postId;
  const FeedPostLiked(this.postId);

  @override
  List<Object?> get props => [postId];
}

class FeedPostEdited extends FeedEvent {
  final String postId;
  final String content;
  final bool removeImage;
  final File? imageFile;

  const FeedPostEdited({
    required this.postId,
    required this.content,
    this.removeImage = false,
    this.imageFile,
  });

  @override
  List<Object?> get props => [postId, content, removeImage, imageFile];
}

class FeedPostDeleted extends FeedEvent {
  final String postId;

  const FeedPostDeleted({required this.postId});

  @override
  List<Object?> get props => [postId];
}
