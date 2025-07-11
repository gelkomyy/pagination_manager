part of 'pagination_manager_cubit_with_search.dart';

/// Base class for all pagination manager with search states.
@immutable
abstract class PaginationManagerWithSearchState {}

/// Initial state when the cubit is first created.
class PaginationManagerWithSearchInitial
    extends PaginationManagerWithSearchState {}

/// Loading state when fetching initial items or performing search.
class PaginationManagerWithSearchLoading
    extends PaginationManagerWithSearchState {}

/// Loading state when fetching next page (pagination).
class LoadingFromPagination extends PaginationManagerWithSearchState {}

/// Success state when items are loaded successfully.
class FetchItemsLoaded<T> extends PaginationManagerWithSearchState {
  final List<T> items;
  final String? errMessageFromPagination;

  FetchItemsLoaded(this.items, {this.errMessageFromPagination});
}

/// Error state when fetching items fails.
class FetchItemsFailure extends PaginationManagerWithSearchState {
  final String message;

  FetchItemsFailure(this.message);
}
