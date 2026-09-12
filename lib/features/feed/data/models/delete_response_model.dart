import 'package:equatable/equatable.dart';

/// Generic delete response model for DELETE endpoints.
class DeleteResponseModel extends Equatable {
  final bool success;

  const DeleteResponseModel({
    required this.success,
  });

  factory DeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteResponseModel(
      success: json['success'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [success];
}
