import 'package:equatable/equatable.dart';

/// A single post in the professional feed.
class FeedPost extends Equatable {
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

  const FeedPost({
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
    this.piiFlagged = false,
    required this.createdAt,
  });

  FeedPost copyWith({
    String? id,
    String? author,
    String? authorId,
    String? headline,
    String? initials,
    String? color,
    String? photo,
    bool clearPhoto = false,
    String? postType,
    String? postTypeDisplay,
    String? content,
    String? image,
    bool clearImage = false,
    int? likeCount,
    int? commentCount,
    bool? liked,
    bool? isMine,
    bool? piiFlagged,
    String? createdAt,
  }) {
    return FeedPost(
      id: id ?? this.id,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      headline: headline ?? this.headline,
      initials: initials ?? this.initials,
      color: color ?? this.color,
      photo: clearPhoto ? null : (photo ?? this.photo),
      postType: postType ?? this.postType,
      postTypeDisplay: postTypeDisplay ?? this.postTypeDisplay,
      content: content ?? this.content,
      image: clearImage ? null : (image ?? this.image),
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      liked: liked ?? this.liked,
      isMine: isMine ?? this.isMine,
      piiFlagged: piiFlagged ?? this.piiFlagged,
      createdAt: createdAt ?? this.createdAt,
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
