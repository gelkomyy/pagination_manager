import 'package:pagination_manager/src/pagination_result/pagination_result.dart';

/// Interface for fetching paginated items from a repository.
abstract class PaginatedRepository<T> {
  /// Fetches a page of paginated items from the repository.
  Future<PaginationResult<T>> fetchPaginatedItems(int page, int limitPerPage);
}
