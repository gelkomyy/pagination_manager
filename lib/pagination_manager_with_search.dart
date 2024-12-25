import 'package:pagination_manager/pagination_manager.dart';

/// A class that holds a [PaginationManager] and a [PaginationSearchManager].
///
/// This class is used to manage pagination and search functionality together.

class PaginationManagerWithSearch<T> {
  /// the Interface for fetching paginated items from a repository.
  final PaginatedRepositoryWithSearch<T> repositoryWithSearch;

  /// Items per page.
  final int limitPerPage;

  /// Items per page in search.
  final int limitPerPageInSearch;

  /// The [PaginationManager] instance.
  late PaginationManager<T> paginationManager;

  /// The [PaginationSearchManager] instance.
  late PaginationSearchManager<T> paginationSearchManager;

  /// Constructor for the [PaginationManagerWithSearch] class.
  ///
  /// This class is used to manage pagination and search functionality together.
  ///
  PaginationManagerWithSearch({
    required this.repositoryWithSearch,
    this.limitPerPage = 20,
    this.limitPerPageInSearch = 20,
  }) {
    /// Initialize the [PaginationManager] instance.
    paginationManager = PaginationManager<T>(
        repository: repositoryWithSearch, limitPerPage: limitPerPage);

    /// Initialize the [PaginationSearchManager] instance.
    paginationSearchManager = PaginationSearchManager<T>(
        repository: repositoryWithSearch, limitPerPage: limitPerPageInSearch);
  }
}
