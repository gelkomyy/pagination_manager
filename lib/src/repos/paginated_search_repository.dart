import 'package:pagination_manager/pagination_manager.dart';

/// Interface for fetching paginated search items from a repository.
abstract class PaginatedSearchRepository<T> {
  /// Fetches a page of paginated search items from the repository.
  Future<PaginationResult<T>> fetchPaginatedSearchItems(
      {required String keyword, required int page, required int limitPerPage});
}
