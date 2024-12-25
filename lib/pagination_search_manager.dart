import 'package:pagination_manager/pagination_manager.dart';

/// A class for managing paginated search data.
///
/// It provides methods for fetching paginated search items and resetting the manager to its initial state.
///
/// The [PaginationSearchManager] class is generic and can be used with any type of data.
class PaginationSearchManager<T> {
  /// Creates a new instance of [PaginationSearchManager].
  ///
  /// [repository] - The implemented repository for fetching search paginated items.
  /// [limitPerPage] - The maximum number of items to fetch per page.
  ///    Defaults to 20.
  ///
  /// Throw an [Exception] if [page] or [limitPerPage] is less than 1.
  ///

  PaginationSearchManager({required this.repository, this.limitPerPage = 20});

  ///  The implemented repository for fetching paginated items.
  final PaginatedSearchRepository<T> repository;

  ///  The maximum number of items to fetch per page.
  final int limitPerPage;

  int _currentPage = 1;
  String? _currentKeyword;
  bool _isLoading = false;
  bool _hasMore = true;

  final List<T> _items = [];

  ///  The current items.
  List<T> get items => List.unmodifiable(_items);

  ///  The current keyword of search.
  String? get currentKeyword => _currentKeyword;

  ///  Sets the current keyword of search.
  set changeCurrentKeyword(String keyword) => _currentKeyword = keyword;

  ///  Indicates whether there are more items to load.
  bool get hasMore => _hasMore;

  /// The current loading state.
  bool get isLoading => _isLoading;

  /// A method for fetching the next page of items in a search.
  Future<PaginationResult<T>> fetchNextPageforCurrentSearchKeyword() async {
    if (_currentPage <= 0 || limitPerPage <= 0) {
      throw Exception('Invalid page or limitPerPage.');
    }
    if (_isLoading || !_hasMore || _currentKeyword == null) {
      return PaginationResult.success(_items);
    }

    _isLoading = true;

    final result = await repository.fetchPaginatedSearchItems(
      keyword: _currentKeyword!,
      page: _currentPage,
      limitPerPage: limitPerPage,
    );
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
