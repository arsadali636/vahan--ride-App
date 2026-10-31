import 'package:equatable/equatable.dart';

sealed class PostComposerEvent extends Equatable {
  const PostComposerEvent();

  @override
  List<Object?> get props => [];
}

class PostTypeChanged extends PostComposerEvent {
  final String postType;
  const PostTypeChanged(this.postType);

  @override
  List<Object?> get props => [postType];
}

class AnonymousToggled extends PostComposerEvent {
  final bool isAnonymous;
  const AnonymousToggled(this.isAnonymous);

  @override
  List<Object?> get props => [isAnonymous];
}

class PostImageSelected extends PostComposerEvent {
  final String? imagePath;
  final String? imageName;
  final List<int>? imageBytes;

  const PostImageSelected(this.imagePath, {this.imageName, this.imageBytes});

  @override
  List<Object?> get props => [imagePath, imageName, imageBytes];
}

class PostImageRemoved extends PostComposerEvent {
  const PostImageRemoved();
}

class PostSubmitted extends PostComposerEvent {
  final String content;
  const PostSubmitted(this.content);

  @override
  List<Object?> get props => [content];
}
