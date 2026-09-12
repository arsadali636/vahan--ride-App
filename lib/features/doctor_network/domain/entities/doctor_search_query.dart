import 'package:equatable/equatable.dart';

/// Search parameters for the doctor discovery endpoint.
///
/// Mirrors `GET /api/v1/doctors/search/` query parameters. `search`,
/// `specialty`, `city`, `experienceMin` and `openToOpportunities` are optional
/// filters; null values are omitted from the request. `page` is 1-based and
/// `pageSize` is capped at 100 by the backend (default 20).
class DoctorSearchQuery extends Equatable {
  final String? search;
  final String? specialty;
  final String? city;
  final double? experienceMin;
  final bool? openToOpportunities;
  final int page;
  final int pageSize;

  const DoctorSearchQuery({
    this.search,
    this.specialty,
    this.city,
    this.experienceMin,
    this.openToOpportunities,
    this.page = 1,
    this.pageSize = 20,
  });

  DoctorSearchQuery copyWith({
    String? search,
    String? specialty,
    String? city,
    double? experienceMin,
    bool? openToOpportunities,
    int? page,
    int? pageSize,
  }) {
    return DoctorSearchQuery(
      search: search ?? this.search,
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
      experienceMin: experienceMin ?? this.experienceMin,
      openToOpportunities: openToOpportunities ?? this.openToOpportunities,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        search,
        specialty,
        city,
        experienceMin,
        openToOpportunities,
        page,
        pageSize,
      ];
}
