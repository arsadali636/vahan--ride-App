// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_feed_posts_usecase.dart';
import 'post_composer_event.dart';
import 'post_composer_state.dart';

class PostComposerBloc extends Bloc<PostComposerEvent, PostComposerState> {
  PostComposerBloc({required CreatePost createPost})
    : _createPost = createPost,
      super(const PostComposerState()) {
    on<PostTypeChanged>(_onPostTypeChanged);
    on<AnonymousToggled>(_onAnonymousToggled);
    on<PostImageSelected>(_onImageSelected);
    on<PostImageRemoved>(_onImageRemoved);
    on<PostSubmitted>(_onSubmitted);
  }

  final CreatePost _createPost;

  void _onPostTypeChanged(
    PostTypeChanged event,
    Emitter<PostComposerState> emit,
  ) {
    emit(state.copyWith(postType: event.postType, clearError: true));
    // Reset anonymous when switching away from CASE
    if (event.postType != 'CASE' && state.isAnonymous) {
      emit(state.copyWith(isAnonymous: false));
    }
  }

  void _onAnonymousToggled(
    AnonymousToggled event,
    Emitter<PostComposerState> emit,
  ) {
    emit(state.copyWith(isAnonymous: event.isAnonymous));
  }

  void _onImageSelected(
    PostImageSelected event,
    Emitter<PostComposerState> emit,
  ) {
    emit(state.copyWith(imagePath: event.imagePath, clearError: true));
  }

  void _onImageRemoved(
    PostImageRemoved event,
    Emitter<PostComposerState> emit,
  ) {
    emit(state.copyWith(clearImage: true, clearError: true));
  }

  Future<void> _onSubmitted(
    PostSubmitted event,
    Emitter<PostComposerState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    emit(
      state.copyWith(status: PostComposerStatus.submitting, clearError: true),
    );

    try {
      File? imageFile;
      if (state.imagePath != null) {
        imageFile = File(state.imagePath!);
      }

      await _createPost(
        content: content,
        postType: state.postType,
        isAnonymous: state.isAnonymous,
        imageFile: imageFile,
      );

      emit(state.copyWith(status: PostComposerStatus.success));
    } on Failure catch (e) {
      emit(state.copyWith(status: PostComposerStatus.failure, error: e));
    }
  }
}
