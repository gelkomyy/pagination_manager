import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_manager/pagination_manager_with_search.dart';
import 'package:pagination_manager/src/paginated_list/error_text_with_retry.dart';
import 'package:pagination_manager/src/paginated_list/paginated_list_with_search_manager.dart';
import 'package:pagination_manager/src/paginated_manager_list/custom_value_notifier_listener.dart';
import 'package:pagination_manager/src/pagination_manager_cubit/pagination_manager_cubit_with_search.dart';

/// A versatile widget for displaying a paginated list with robust error handling,
/// refresh capabilities, and lazy loading. This widget integrates with the
/// [PaginationManagerCubitWithSearch] to efficiently manage pagination, loading, and error states.
///
/// Features:
/// - **Lazy loading**: Automatically fetches more items as the user scrolls near the bottom of the list.
/// - **Customizable UI**: Customize error messages, empty item states, and loading indicators.
/// - **Error handling**: Displays error messages with an optional retry button, along with a custom handler for pagination errors.
/// - **Refresh and retry**: Supports pull-to-refresh functionality and retry button for error recovery.
/// - **Flexible**: Supports horizontal and vertical scrolling, and enables custom behavior for loading, empty state, and error states.

class PaginatedManagerListWithSearchManager<T> extends StatelessWidget {
  /// Constructor for the [PaginatedManagerListWithSearchManager] widget.
  ///
  /// The [PaginationManagerWithSearch] instance responsible for tracking pagination and search state.
  ///
  /// [paginationManagerWithSearch] must not be null.
  /// [scrollThreshold] must be between 0.0 and 1.0 (inclusive).
  const PaginatedManagerListWithSearchManager({
    super.key,
    required this.paginationManagerWithSearch,
    required this.itemBuilder,
    required this.searchValueNotifier,
    this.loadingPaginationWidget,
    this.emptyItemsWidget,
    this.whenErrMessageFromPagination,
    this.fetchItemsFailureWidget,
    this.notSpecifiedWidget,
    this.notSpecifiedErrorMessage = 'Something went wrong',
    this.emptyItemsText = 'Empty Items',
    this.retryText = 'Retry',
    this.scrollThreshold = 0.90,
    this.shrinkWrap = false,
    this.showRefreshIndicator = true,
    this.showRetryButtonForSearch = true,
    this.showRetryButton = true,
    this.showRefreshIndicatorForSearch = true,
    this.scrollDirection = Axis.vertical,
    this.initialLoadingWidget = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.errorTextStyle,
    this.retryTextStyle,
    this.retryButtonStyle,
    this.onSearchChanged,
  }) : assert(scrollThreshold >= 0.0 && scrollThreshold <= 1.0,
            'scrollThreshold must be between 0.0 and 1.0');

  /// A bool indicating whether to show a refresh indicator (Pull to refresh).
  final bool showRefreshIndicator;

  /// A bool indicating whether to show a refresh indicator for search.
  final bool showRefreshIndicatorForSearch;

  /// A bool indicating whether to show a retry button.
  final bool showRetryButton;

  /// A bool indicating whether to show a retry button for search.
  final bool showRetryButtonForSearch;

  /// The text displayed when the list of items is empty.
  final String emptyItemsText;

  /// The pagination manager with search instance responsible for tracking pagination and search state.
  final PaginationManagerWithSearch<T> paginationManagerWithSearch;

  /// The threshold for triggering pagination as a percentage of the scrollable area.
  /// Must be between 0.0 and 1.0.
  final double scrollThreshold;

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

  /// A callback function invoked when an error occurs during pagination.
  final Function(String message)? whenErrMessageFromPagination;

  /// A widget displayed when an error occurs during initial fetch Items.
  final Widget Function(String errorMessage)? fetchItemsFailureWidget;

  /// A message to display when the State is PaginationManagerWithSearchInitial.
  final String notSpecifiedErrorMessage;

  /// A widget displayed when the State is PaginationManagerWithSearchInitial.
  final Widget? notSpecifiedWidget;

  /// A widget displayed during initial loading.
  final Widget initialLoadingWidget;

  /// The text displayed on the retry button.
  final String retryText;

  /// The text style for the error message.
  final TextStyle? errorTextStyle;

  /// The text style for the retry button.
  final TextStyle? retryTextStyle;

  /// The button style for the retry button.
  final ButtonStyle? retryButtonStyle;

  /// External ValueNotifier for search text (for search fields).
  /// By provided, you can create your own search field and bind it to this notifier.
  /// The widget will listen to changes and trigger search automatically.
  final ValueNotifier<String> searchValueNotifier;

  /// Callback function called when searchValueNotifier changes.
  final void Function(String query)? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaginationManagerCubitWithSearch<T>(paginationManagerWithSearch)
            ..fetchInitialItems(),
      child: Builder(builder: (context) {
        return CustomValueNotifierListener(
          valueNotifier: searchValueNotifier,
          onValueChanged: (keyword) {
            context
                .read<PaginationManagerCubitWithSearch<T>>()
                .searchItems(keyword);
            onSearchChanged?.call(keyword);
          },
          child: BlocConsumer<PaginationManagerCubitWithSearch<T>,
              PaginationManagerWithSearchState>(
            listenWhen: (previous, current) => (current is FetchItemsLoaded &&
                current.errMessageFromPagination != null),
            listener: (context, state) {
              if (state is FetchItemsLoaded &&
                  state.errMessageFromPagination != null &&
                  whenErrMessageFromPagination != null) {
                whenErrMessageFromPagination!(state.errMessageFromPagination!);
              }
            },
            builder: (context, state) {
              final PaginationManagerCubitWithSearch<T> cubit =
                  context.read<PaginationManagerCubitWithSearch<T>>();
              final bool isFromSearch = cubit.paginationManagerWithSearch
                  .paginationSearchManager.currentKeyword.isNotEmpty;
              final String currentSearchKeyword = cubit
                  .paginationManagerWithSearch
                  .paginationSearchManager
                  .currentKeyword;

              if (state is FetchItemsLoaded || state is LoadingFromPagination) {
                return PaginatedListWithSearchManager<T>(
                  paginationManagerWithSearch:
                      cubit.paginationManagerWithSearch,
                  itemBuilder: itemBuilder,
                  fetchNextPageForSearch:
                      cubit.fetchNextPageforCurrentSearchKeyword,
                  onRetryForSearch: showRetryButtonForSearch
                      ? () => cubit.searchItems(currentSearchKeyword)
                      : null,
                  onRefreshForSearch: showRefreshIndicatorForSearch
                      ? () => cubit.searchItems(currentSearchKeyword)
                      : null,
                  fetchNextPage: cubit.fetchNextPage,
                  errorTextStyle: errorTextStyle,
                  retryText: retryText,
                  retryTextStyle: retryTextStyle,
                  emptyItemsWidget: emptyItemsWidget,
                  onRetry: showRetryButton ? cubit.fetchInitialItems : null,
                  onRefresh:
                      showRefreshIndicator ? cubit.fetchInitialItems : null,
                  loadingFromPaginationState: state is LoadingFromPagination,
                  loadingPaginationWidget: loadingPaginationWidget,
                  emptyItemsText: emptyItemsText,
                  scrollThreshold: scrollThreshold,
                  shrinkWrap: shrinkWrap,
                  scrollDirection: scrollDirection,
                  retryButtonStyle: retryButtonStyle,
                );
              } else if (state is PaginationManagerWithSearchLoading) {
                return initialLoadingWidget;
              } else if (state is FetchItemsFailure) {
                return fetchItemsFailureWidget?.call(state.message) ??
                    ErrorTextWithRetry(
                      errorText: state.message,
                      errorTextStyle: errorTextStyle,
                      retryTextStyle: retryTextStyle,
                      retryButtonStyle: retryButtonStyle,
                      retryText: retryText,
                      onRetry: (showRetryButton ||
                              (isFromSearch && showRetryButtonForSearch))
                          ? () {
                              if (!isFromSearch) {
                                cubit.fetchInitialItems();
                              } else {
                                cubit.searchItems(currentSearchKeyword);
                              }
                            }
                          : null,
                    );
              } else {
                return notSpecifiedWidget ??
                    ErrorTextWithRetry(
                      errorText: notSpecifiedErrorMessage,
                      errorTextStyle: errorTextStyle,
                      retryTextStyle: retryTextStyle,
                      retryText: retryText,
                      retryButtonStyle: retryButtonStyle,
                      onRetry: (showRetryButton ||
                              (isFromSearch && showRetryButtonForSearch))
                          ? () {
                              if (!isFromSearch) {
                                cubit.fetchInitialItems();
                              } else {
                                cubit.searchItems(currentSearchKeyword);
                              }
                            }
                          : null,
                    );
              }
            },
          ),
        );
      }),
    );
  }
}
