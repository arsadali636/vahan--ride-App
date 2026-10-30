import 'package:equatable/equatable.dart';

import '../../domain/entities/feed_post.dart';

/// Wire-format model for a single feed post.
class FeedPostModel extends Equatable {
  final String id;
  final String author;
  final String authorId;
  final String headline;
  final String initials;
  final String color;
  final String? photo;
  final String postType;
  final String postTypeDisplay;
  final String content;
  final String? image;
  final int likeCount;
  final int commentCount;
  final bool liked;
  final bool isMine;
  final bool piiFlagged;
  final String createdAt;

  const FeedPostModel({
    required this.id,
    required this.author,
    required this.authorId,
    required this.headline,
    required this.initials,
    required this.color,
    this.photo,
    required this.postType,
    required this.postTypeDisplay,
    required this.content,
    this.image,
    required this.likeCount,
    required this.commentCount,
    required this.liked,
    required this.isMine,
    required this.piiFlagged,
    required this.createdAt,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    return FeedPostModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      color: json['color'] as String? ?? '',
      photo: json['photo'] as String?,
      postType: json['post_type'] as String? ?? '',
      postTypeDisplay: json['post_type_display'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      piiFlagged: json['pii_flagged'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  FeedPost toEntity() {
    return FeedPost(
      id: id,
      author: author,
      authorId: authorId,
      headline: headline,
      initials: initials,
      color: color,
      photo: photo,
      postType: postType,
      postTypeDisplay: postTypeDisplay,
      content: content,
      image: image,
      likeCount: likeCount,
      commentCount: commentCount,
      liked: liked,
      isMine: isMine,
      piiFlagged: piiFlagged,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    authorId,
    headline,
    initials,
    color,
    photo,
    postType,
    postTypeDisplay,
    content,
    image,
    likeCount,
    commentCount,
    liked,
    isMine,
    piiFlagged,
    createdAt,
  ];
}
