import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_search_result.dart';
import '../../domain/entities/paginated_result.dart';
import 'doctor_search_result_model.dart';

/// Paginated envelope returned by `GET /api/v1/doctors/search/`.
///
/// Observed live shape: `{total, page, page_size, results}`. The `results`
/// array items follow the public doctor shape (see [DoctorSearchResultModel]).
class DoctorSearchResponseModel extends Equatable {
  final int total;
  final int page;
  final int pageSize;
  final List<DoctorSearchResultModel> results;

  const DoctorSearchResponseModel({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.results,
  });

  factory DoctorSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return DoctorSearchResponseModel(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      results: (json['results'] as List? ?? const [])
          .whereType<Map>()
          .map((e) =>
              DoctorSearchResultModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  PaginatedResult<DoctorSearchResult> toEntity() {
    return PaginatedResult<DoctorSearchResult>(
      items: results.map((e) => e.toEntity()).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  List<Object?> get props => [total, page, pageSize, results];
}
