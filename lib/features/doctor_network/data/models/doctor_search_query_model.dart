import '../../domain/entities/doctor_search_query.dart';

/// Wire adapter for [DoctorSearchQuery].
///
/// Converts domain values into the exact query parameters accepted by
/// `GET /api/v1/doctors/search/` (`search`, `specialty`, `city`,
/// `experience_min`, `open_to_opportunities`, `page`, `page_size`). Null
/// filters are omitted from the request; only `page` and `page_size` are
/// always present.
class DoctorSearchQueryModel {
  final String? search;
  final String? specialty;
  final String? city;
  final double? experienceMin;
  final bool? openToOpportunities;
  final int page;
  final int pageSize;

  const DoctorSearchQueryModel({
    this.search,
    this.specialty,
    this.city,
    this.experienceMin,
    this.openToOpportunities,
    this.page = 1,
    this.pageSize = 20,
  });

  factory DoctorSearchQueryModel.fromDomain(DoctorSearchQuery query) {
    return DoctorSearchQueryModel(
      search: query.search,
      specialty: query.specialty,
      city: query.city,
      experienceMin: query.experienceMin,
      openToOpportunities: query.openToOpportunities,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  /// Query parameters to send to the search endpoint.
  Map<String, dynamic> toQueryParameters() {
    final trimmedSearch = search?.trim();
    final trimmedSpecialty = specialty?.trim();
    final trimmedCity = city?.trim();
    return {
      if (trimmedSearch != null && trimmedSearch.isNotEmpty)
        'search': trimmedSearch,
      if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty)
        'specialty': trimmedSpecialty,
      if (trimmedCity != null && trimmedCity.isNotEmpty) 'city': trimmedCity,
      if (experienceMin != null) 'experience_min': experienceMin,
      if (openToOpportunities != null)
        'open_to_opportunities': openToOpportunities,
      'page': page,
      'page_size': pageSize,
    };
  }
}
