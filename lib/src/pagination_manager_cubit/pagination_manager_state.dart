part of 'pagination_manager_cubit.dart';

@immutable
sealed class PaginationManagerState {}

final class PaginationManagerInitial extends PaginationManagerState {}

final class PaginationManagerLoading extends PaginationManagerState {}

final class LoadingFromPagination extends PaginationManagerState {}

final class FetchItemsLoaded<T> extends PaginationManagerState {
  final List<T> items;
  final String? errMessageFromPagination;
  FetchItemsLoaded(this.items, {this.errMessageFromPagination});
}

final class FetchItemsFailure extends PaginationManagerState {
  final String message;

  FetchItemsFailure(this.message);
}
