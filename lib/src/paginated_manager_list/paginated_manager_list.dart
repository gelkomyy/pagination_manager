import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_manager/pagination_manager.dart';
import 'package:pagination_manager/src/paginated_list/error_text_with_retry.dart';

/// A versatile widget for displaying a paginated list with robust error handling,
/// refresh capabilities, and lazy loading. This widget integrates with the
/// [PaginationManagerCubit] to efficiently manage pagination, loading, and error states.
///
/// Features:
/// - **Lazy loading**: Automatically fetches more items as the user scrolls near the bottom of the list.
/// - **Customizable UI**: Customize error messages, empty item states, and loading indicators.
/// - **Error handling**: Displays error messages with an optional retry button, along with a custom handler for pagination errors.
/// - **Refresh and retry**: Supports pull-to-refresh functionality and retry button for error recovery.
/// - **Flexible**: Supports horizontal and vertical scrolling, and enables custom behavior for loading, empty state, and error states.

class PaginatedManagerList<T> extends StatelessWidget {
  /// Constructor for the [PaginatedManagerList] widget.
  ///
  ///   The [PaginationManager] instance responsible for tracking pagination state, Note: Items in PaginationManager.
  ///
  /// [paginationManager] must not be null.
  /// [scrollThreshold] must be between 0.0 and 1.0 (inclusive).
  const PaginatedManagerList({
    super.key,
    required this.paginationManager,
    required this.itemBuilder,
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
    this.showRetryButton = true,
    this.scrollDirection = Axis.vertical,
    this.initialLoadingWidget = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.errorTextStyle,
    this.retryTextStyle,
    this.retryButtonStyle,
  }) : assert(scrollThreshold >= 0.0 && scrollThreshold <= 1.0,
            'scrollThreshold must be between 0.0 and 1.0');

  ///   A bool indicating whether to show a refresh indicator (Pull to refresh).
  final bool showRefreshIndicator;

  ///   A bool indicating whether to show a retry button.
  final bool showRetryButton;

  ///   The text displayed when the list of items is empty.
  final String emptyItemsText;

  ///   The pagination manager instance responsible for tracking pagination state, Note: Items in PaginationManager.
  final PaginationManager<T> paginationManager;

  ///   The threshold for triggering pagination as a percentage of the scrollable area.
  ///   Must be between 0.0 and 1.0.
  final double scrollThreshold;

  ///   A widget displayed at the end of the list during pagination loading.
  final Widget? loadingPaginationWidget;

  ///   Whether the list should shrink-wrap its content.
  final bool shrinkWrap;

  ///   The scroll direction of the list (vertical or horizontal).
  final Axis scrollDirection;

  ///   A builder function to create widgets for each item in the list.
  final Widget? Function(BuildContext, int, List<T>) itemBuilder;

  ///   A widget displayed when the list of items is empty.
  final Widget? emptyItemsWidget;

  ///   A callback function invoked when an error occurs during pagination, Note: errorMessage from PaginationResult.failure.
  final Function(String message)? whenErrMessageFromPagination;

  ///   A widget displayed when an error occurs during initial fetch Items, Note: errorMessage from PaginationResult.failure.
  final Widget Function(String errorMessage)? fetchItemsFailureWidget;

  ///   A message to display when the State is PaginationManagerInitial.
  final String notSpecifiedErrorMessage;

  ///   A widget displayed when the State is PaginationManagerInitial.
  final Widget? notSpecifiedWidget;

  ///   A widget displayed during initial loading.
  final Widget initialLoadingWidget;

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
    return BlocProvider(
      create: (context) =>
          PaginationManagerCubit<T>(paginationManager)..fetchInitialItems(),
      child: Builder(builder: (context) {
        return BlocConsumer<PaginationManagerCubit<T>, PaginationManagerState>(
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
            final PaginationManagerCubit<T> paginationManagerCubit =
                context.read<PaginationManagerCubit<T>>();
            if (state is FetchItemsLoaded || state is LoadingFromPagination) {
              return PaginatedList<T>(
                paginationManager: paginationManagerCubit.paginationManager,
                itemBuilder: itemBuilder,
                retryText: retryText,
                errorTextStyle: errorTextStyle,
                retryTextStyle: retryTextStyle,
                retryButtonStyle: retryButtonStyle,
                fetchNextPage: paginationManagerCubit.fetchNextPage,
                loadingFromPaginationState: state is LoadingFromPagination,
                loadingPaginationWidget: loadingPaginationWidget,
                emptyItemsText: emptyItemsText,
                emptyItemsWidget: emptyItemsWidget,
                scrollThreshold: scrollThreshold,
                shrinkWrap: shrinkWrap,
                scrollDirection: scrollDirection,
                onRetry: showRetryButton
                    ? paginationManagerCubit.fetchInitialItems
                    : null,
                onRefresh: showRefreshIndicator
                    ? paginationManagerCubit.fetchInitialItems
                    : null,
              );
            } else if (state is PaginationManagerLoading) {
              return initialLoadingWidget;
            } else if (state is FetchItemsFailure) {
              return fetchItemsFailureWidget?.call(state.message) ??
                  ErrorTextWithRetry(
                    errorText: state.message,
                    errorTextStyle: errorTextStyle,
                    retryTextStyle: retryTextStyle,
                    retryButtonStyle: retryButtonStyle,
                    retryText: retryText,
                    onRetry: showRetryButton
                        ? paginationManagerCubit.fetchInitialItems
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
                      onRetry: showRetryButton
                          ? paginationManagerCubit.fetchInitialItems
                          : null);
            }
          },
        );
      }),
    );
  }
}
