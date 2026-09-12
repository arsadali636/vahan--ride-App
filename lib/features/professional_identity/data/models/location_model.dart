import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';

/// Wire model for the backend `Location` schema.
///
/// The backend serializes an empty `professional_location` as `{}`, which
/// parses to `null` here so downstream code can treat "no location" and
/// "missing location" identically.
class LocationModel extends Equatable {
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final Map<String, dynamic>? coordinates;

  const LocationModel({
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      address: json['address'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String?,
      coordinates: json['coordinates'] as Map<String, dynamic>?,
    );
  }

  /// Parses a wire `professional_location` value. Empty maps and nulls
  /// collapse to `null` (the backend uses `{}` for "no location").
  static Location? fromMapOrNull(dynamic value) {
    if (value is! Map<String, dynamic> || value.isEmpty) return null;
    return LocationModel.fromJson(value).toEntity();
  }

  static LocationModel fromEntity(Location location) {
    return LocationModel(
      address: location.address,
      city: location.city,
      state: location.state,
      pincode: location.pincode,
      coordinates: location.coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (coordinates != null) 'coordinates': coordinates,
    };
  }

  Location toEntity() {
    return Location(
      address: address,
      city: city ?? '',
      state: state ?? '',
      pincode: pincode,
      coordinates: coordinates,
    );
  }

  @override
  List<Object?> get props => [address, city, state, pincode, coordinates];
}
