import 'package:equatable/equatable.dart';

/// A generic, backend-shaped paginated page of items.
///
/// The backend search endpoint returns `{total, page, page_size, results}`.
/// [hasMore] derives from those numbers so the UI can decide whether to keep
/// requesting the next page.
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => page * pageSize < total;

  @override
  List<Object?> get props => [items, total, page, pageSize];
}
