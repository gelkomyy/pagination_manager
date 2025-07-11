import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_manager/pagination_manager.dart';

part 'pagination_manager_with_search_state.dart';

/// A [Cubit] that manages a [PaginationManagerWithSearch] and emits [PaginationManagerWithSearchState]s.
/// It provides methods to fetch initial items, fetch the next page of items, and search functionality.
class PaginationManagerCubitWithSearch<T>
    extends Cubit<PaginationManagerWithSearchState> {
  PaginationManagerCubitWithSearch(this._paginationManagerWithSearch)
      : super(PaginationManagerWithSearchInitial());

  final PaginationManagerWithSearch<T> _paginationManagerWithSearch;
  final _debounceDuration = const Duration(milliseconds: 300);
  Timer? _debounceTimer;

  List<T> get currentItems => _isSearchMode
      ? _paginationManagerWithSearch.paginationSearchManager.items
      : _paginationManagerWithSearch.paginationManager.items;

  PaginationManagerWithSearch<T> get paginationManagerWithSearch =>
      _paginationManagerWithSearch;

  bool get _isSearchMode => _paginationManagerWithSearch
      .paginationSearchManager.currentKeyword.isNotEmpty;

  /// Fetches initial items from the [PaginationManager] and emits [FetchItemsLoaded] or [FetchItemsFailure] states.
  Future<void> fetchInitialItems() async {
    _paginationManagerWithSearch.paginationManager.reset();
    _paginationManagerWithSearch.paginationSearchManager.reset();
    emit(PaginationManagerWithSearchLoading());

    final result =
        await _paginationManagerWithSearch.paginationManager.fetchNextPage();
    result.when(
      failure: (failureMessage) => emit(FetchItemsFailure(failureMessage)),
      success: (items) => emit(FetchItemsLoaded<T>(
          _paginationManagerWithSearch.paginationManager.items)),
    );
  }

  /// Fetches the next page of items from the [PaginationManager] and emits [LoadingFromPagination] state or [FetchItemsLoaded] or [FetchItemsLoaded] with an errorMessage.
  Future<void> fetchNextPage() async {
    emit(LoadingFromPagination());
    final result =
        await _paginationManagerWithSearch.paginationManager.fetchNextPage();
    result.when(
      failure: (failureMessage) => emit(FetchItemsLoaded<T>(
        _paginationManagerWithSearch.paginationManager.items,
        errMessageFromPagination: failureMessage,
      )),
      success: (items) => emit(FetchItemsLoaded<T>(
          _paginationManagerWithSearch.paginationManager.items)),
    );
  }

  /// Searches for items with the given keyword and emits appropriate states.
  Future<void> searchItems(String keyword) async {
    _debounceTimer?.cancel();
    _paginationManagerWithSearch.paginationSearchManager.reset();
    _paginationManagerWithSearch.paginationSearchManager.changeCurrentKeyword =
        keyword;

    _debounceTimer = Timer(_debounceDuration, () async {
      if (keyword.isEmpty) {
        emit(FetchItemsLoaded<T>(
            _paginationManagerWithSearch.paginationManager.items));
        _debounceTimer?.cancel();
        return;
      }

      emit(PaginationManagerWithSearchLoading());

      final result = await _paginationManagerWithSearch.paginationSearchManager
          .fetchNextPageforCurrentSearchKeyword();
      result.when(
        failure: (failureMessage) => emit(FetchItemsFailure(failureMessage)),
        success: (items) => emit(FetchItemsLoaded<T>(
            _paginationManagerWithSearch.paginationSearchManager.items)),
      );
    });
  }

  /// Fetches the next page for the current search keyword.
  Future<void> fetchNextPageforCurrentSearchKeyword() async {
    emit(LoadingFromPagination());
    final result = await _paginationManagerWithSearch.paginationSearchManager
        .fetchNextPageforCurrentSearchKeyword();
    result.when(
      failure: (failureMessage) => emit(FetchItemsLoaded<T>(
        _paginationManagerWithSearch.paginationSearchManager.items,
        errMessageFromPagination: failureMessage,
      )),
      success: (items) => emit(FetchItemsLoaded<T>(
          _paginationManagerWithSearch.paginationSearchManager.items)),
    );
  }

  /// Clears the search and returns to the regular pagination mode.
  Future<void> clearSearch() async {
    _debounceTimer?.cancel();
    _paginationManagerWithSearch.paginationSearchManager.reset();
    emit(FetchItemsLoaded<T>(
        _paginationManagerWithSearch.paginationManager.items));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
