import 'package:flutter/material.dart';
import 'package:pagination_manager/pagination_manager.dart';

import 'error_text_with_retry.dart';

/// A widget that displays a paginated list with optional refresh and error handling capabilities.
///
/// This widget supports lazy loading of data when the user scrolls near the end of the list.
/// It also allows displaying a custom empty state widget, error retry option, and refresh capability.
class PaginatedListWithSearchManager<T> extends StatelessWidget {
  /// Creates a [PaginatedListWithSearchManager].
  ///
  /// [paginationManagerWithSearch] must not be null.
  /// [fetchNextPage] must not be null.
  /// [loadingFromPaginationState] must not be null.
  /// [scrollThreshold] must be between 0.0 and 1.0 (inclusive).
  const PaginatedListWithSearchManager({
    super.key,
    required this.paginationManagerWithSearch,
    required this.itemBuilder,
    required this.fetchNextPage,
    required this.loadingFromPaginationState,
    this.onRefresh,
    this.onRetry,
    this.loadingPaginationWidget,
    this.emptyItemsText = 'Empty Items',
    this.retryText = 'Retry',
    this.scrollThreshold = 0.90,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.emptyItemsWidget,
    this.errorTextStyle,
    this.retryTextStyle,
    this.retryButtonStyle,
  }) : assert(scrollThreshold >= 0.0 && scrollThreshold <= 1.0,
            'scrollThreshold must be between 0.0 and 1.0');

  /// A callback function invoked when the user retries after an error.
  final void Function()? onRetry;

  /// A callback function invoked when the user performs a pull-to-refresh action.
  final Future<void> Function()? onRefresh;

  /// The text displayed when the list of items is empty.
  final String emptyItemsText;

  /// The pagination manager with search instance responsible for tracking pagination state, Note: Items in PaginationManager.
  final PaginationManagerWithSearch<T> paginationManagerWithSearch;

  /// A callback function invoked to fetch the next page of items.
  final VoidCallback fetchNextPage;

  /// The threshold for triggering pagination as a percentage of the scrollable area.
  /// Must be between 0.0 and 1.0.
  final double scrollThreshold;

  /// Indicates whether the list is currently loading additional items due to pagination, adds an extra loading widget at the bottom(loadingPaginationWidget).
  final bool loadingFromPaginationState;

  /// A widget displayed at the end of the list during pagination loading.
  final Widget? loadingPaginationWidget;

  /// Whether the list should shrink-wrap its content.
  final bool shrinkWrap;

  /// The scroll direction of the list (vertical or horizontal).
  final Axis scrollDirection;

  /// A builder function to create widgets for each item in the list.
  final Widget? Function(BuildContext, int, List<T>) itemBuilder;

  /// A widget displayed when the list of items is empty.
  final Widget? emptyItemsWidget;

  /// The text displayed on the retry button.
  final String retryText;

  ///   The text style for the error message.
  final TextStyle? errorTextStyle;

  ///   The text style for the retry button.
  final TextStyle? retryTextStyle;

  ///   The button style for the retry button.
  final ButtonStyle? retryButtonStyle;
  @override
  Widget build(BuildContext context) {
    final bool isFromSearch =
        paginationManagerWithSearch.paginationSearchManager.currentKeyword !=
            null;
    final List<T> items = !isFromSearch
        ? paginationManagerWithSearch.paginationManager.items
        : paginationManagerWithSearch.paginationSearchManager.items;

    /// Display the empty state if the list of items is empty.
    if (items.isEmpty) {
      return emptyItemsWidget ??
          ErrorTextWithRetry(
            errorText: emptyItemsText,
            errorTextStyle: errorTextStyle,
            retryTextStyle: retryTextStyle,
            retryButtonStyle: retryButtonStyle,
            retryText: retryText,
            onRetry: onRetry,
          );
    }

    /// Listen for scroll notifications to trigger pagination.
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (!isFromSearch) {
          if (!paginationManagerWithSearch.paginationManager.hasMore ||
              paginationManagerWithSearch.paginationManager.isLoading) {
            return true;
          }
        } else {
          if (!paginationManagerWithSearch.paginationSearchManager.hasMore ||
              paginationManagerWithSearch.paginationSearchManager.isLoading) {
            return true;
          }
        }

        if (scrollNotification.metrics.pixels >
            scrollNotification.metrics.maxScrollExtent * scrollThreshold) {
          fetchNextPage();
        }

        return false;
      },

      /// Display a refreshable or static list view.
      child: onRefresh == null
          ? ListView.builder(
              itemCount: items.length + (loadingFromPaginationState ? 1 : 0),
              scrollDirection: scrollDirection,
              shrinkWrap: shrinkWrap,
              itemBuilder: (_, index) {
                /// Display the pagination loading widget at the end of the list.
                if (index == items.length) {
                  return loadingPaginationWidget ??
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                }

                /// Build each item in the list.
                return itemBuilder(context, index, items);
              },
            )

          /// Display a refreshable list view with a pull-to-refresh action.
          : RefreshIndicator.adaptive(
              onRefresh: onRefresh!,
              child: ListView.builder(
                itemCount: items.length + (loadingFromPaginationState ? 1 : 0),
                scrollDirection: scrollDirection,
                shrinkWrap: shrinkWrap,
                itemBuilder: (_, index) {
                  /// Display the pagination loading widget at the end of the list.
                  if (index == items.length) {
                    return loadingPaginationWidget ??
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                  }

                  /// Build each item in the list.
                  return itemBuilder(context, index, items);
                },
              ),
            ),
    );
  }
}
