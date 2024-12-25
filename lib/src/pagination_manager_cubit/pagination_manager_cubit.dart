import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_manager/pagination_manager.dart';

part 'pagination_manager_state.dart';

/// A [Cubit] that manages a [PaginationManager] and emits [PaginationManagerState]s.
/// It provides methods to fetch initial items and fetch the next page of items.
class PaginationManagerCubit<T> extends Cubit<PaginationManagerState> {
  PaginationManagerCubit(this._paginationManager)
      : super(PaginationManagerInitial());

  final PaginationManager<T> _paginationManager;
  List<T> get currentItems => _paginationManager.items;
  PaginationManager<T> get paginationManager => _paginationManager;

  /// Fetches initial items from the [PaginationManager] and emits [FetchItemsLoaded] or [FetchItemsFailure] states.
  Future<void> fetchInitialItems() async {
    _paginationManager.reset();
    emit(PaginationManagerLoading());

    final result = await _paginationManager.fetchNextPage();
    result.when(
      failure: (failureMessage) => emit(FetchItemsFailure(failureMessage)),
      success: (items) => emit(FetchItemsLoaded<T>(_paginationManager.items)),
    );
  }

  /// Fetches the next page of items from the [PaginationManager] and emits [LoadingFromPagination] state or [FetchItemsLoaded] or [FetchItemsLoaded] with an errorMessage.
  Future<void> fetchNextPage() async {
    emit(LoadingFromPagination());
    final result = await _paginationManager.fetchNextPage();
    result.when(
      failure: (failureMessage) => emit(FetchItemsLoaded<T>(
        _paginationManager.items,
        errMessageFromPagination: failureMessage,
      )),
      success: (items) => emit(FetchItemsLoaded<T>(_paginationManager.items)),
    );
  }
}
