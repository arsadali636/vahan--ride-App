import 'package:equatable/equatable.dart';

/// A professional location for a doctor profile.
///
/// Mirrors the backend `Location` schema. Only [city] and [state] are
/// required by the API; address, pincode and coordinates are optional.
class Location extends Equatable {
  final String? address;
  final String city;
  final String state;
  final String? pincode;
  final Map<String, dynamic>? coordinates;

  const Location({
    this.address,
    required this.city,
    required this.state,
    this.pincode,
    this.coordinates,
  });

  /// Compact `City, State` label for list rows.
  String get label => [city, state].where((s) => s.isNotEmpty).join(', ');

  @override
  List<Object?> get props => [address, city, state, pincode, coordinates];
}
