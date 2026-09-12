import 'package:equatable/equatable.dart';

/// A suggested doctor entry from the home dashboard.
class SuggestedDoctor extends Equatable {
  final String id;
  final String fullName;
  final String headline;
  final String? photo;
  final String initials;
  final String color;
  final Map<String, dynamic> location;
  final int experienceYears;
  final String verificationStatus;
  final String connectionStatus;
  final String? connectionId;
  final String? connectionDirection;

  const SuggestedDoctor({
    required this.id,
    required this.fullName,
    required this.headline,
    this.photo,
    required this.initials,
    required this.color,
    required this.location,
    required this.experienceYears,
    required this.verificationStatus,
    required this.connectionStatus,
    this.connectionId,
    this.connectionDirection,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        headline,
        photo,
        initials,
        color,
        location,
        experienceYears,
        verificationStatus,
        connectionStatus,
        connectionId,
        connectionDirection,
      ];
}
