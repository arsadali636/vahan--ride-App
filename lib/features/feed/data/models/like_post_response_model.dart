import 'package:equatable/equatable.dart';

/// Wire-format model for the like/unlike post response.
class LikePostResponseModel extends Equatable {
  final bool liked;
  final int count;

  const LikePostResponseModel({required this.liked, required this.count});

  factory LikePostResponseModel.fromJson(Map<String, dynamic> json) {
    return LikePostResponseModel(
      liked: json['liked'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [liked, count];
}
