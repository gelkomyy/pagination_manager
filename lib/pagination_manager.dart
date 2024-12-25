library pagination_manager;

import 'pagination_manager.dart';

export 'src/pagination_result/pagination_result.dart';
export 'src/repos/paginated_repository.dart';
export 'src/paginated_manager_list/paginated_manager_list.dart';
export 'src/pagination_manager_cubit/pagination_manager_cubit.dart';
export 'src/paginated_list/paginated_list.dart';

/// A class for managing paginated data.
///
/// It provides methods for fetching paginated items and resetting the manager to its initial state.
///
/// The [PaginationManager] class is generic and can be used with any type of data.
class PaginationManager<T> {
  /// Creates a new instance of [PaginationManager].
  ///
  /// [repository] - The implemented repository for fetching paginated items.
  /// [limitPerPage] - The maximum number of items to fetch per page.
  ///    Defaults to 20.
  ///
  /// Throw an [Exception] if [page] or [limitPerPage] is less than 1.
  ///

  PaginationManager({required this.repository, this.limitPerPage = 20});

  ///  The implemented repository for fetching paginated items.
  final PaginatedRepository<T> repository;

  ///  The maximum number of items to fetch per page.
  final int limitPerPage;

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  final List<T> _items = [];

  ///  The current items.
  List<T> get items => List.unmodifiable(_items);

  ///  Indicates whether there are more items to load.
  bool get hasMore => _hasMore;

  /// The current loading state.
  bool get isLoading => _isLoading;

  /// A method for fetching the next page of items.
  Future<PaginationResult<T>> fetchNextPage() async {
    if (_currentPage <= 0 || limitPerPage <= 0) {
      throw Exception('Invalid page or limitPerPage.');
    }
    if (_isLoading || !_hasMore) {
      return PaginationResult.success(_items);
    }

    _isLoading = true;

    final result =
        await repository.fetchPaginatedItems(_currentPage, limitPerPage);
    result.when(
      failure: (failure) => _isLoading = false,
      success: (newItems) {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
        if (newItems.length < limitPerPage) {
          _hasMore = false;
        }
      },
    );

    return result;
  }

  ///  Resets the pagination manager to its initial state.
  void reset() {
    _currentPage = 1;
    _items.clear();
    _hasMore = true;
    _isLoading = false;
  }
}
