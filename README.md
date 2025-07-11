# 📦 Pagination Manager

[![Pub Version](https://img.shields.io/pub/v/pagination_manager.svg)](https://pub.dev/packages/pagination_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible Flutter package for handling paginated data with built-in state management support. Easily implement infinite scrolling lists with minimal boilerplate code.

![Demo](assets/demo.gif)

## ✨ Features

*   🚀 Easy-to-use pagination management
*   💪 Built-in Bloc/Cubit state management support
*   🎯 Framework-agnostic - works with any state management solution
*   🔄 Pull-to-refresh support
*   ⚡ Lazy loading with automatic state management
*   🎨 Customizable loading and error states
*   📱 Responsive and adaptive design
*   🔍 **NEW: Built-in search functionality with debouncing**
*   🔧 **NEW: Flexible search field integration (built-in or custom)**
*   ⏱️ **NEW: Intelligent debouncing to optimize API calls**
*   🔄 **NEW: Seamless switching between pagination and search modes**

## 📋 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  pagination_manager: ^1.1.0
```

Then import:

```dart
import 'package:pagination_manager/pagination_manager.dart';
```

## 🚀 Quick Start

### 1. Create a Repository

First, implement the `PaginatedRepository` interface:

```dart
class MyDataRepository implements PaginatedRepository<MyData> {
  @override
  Future<PaginationResult<MyData>> fetchPaginatedItems(int page, int limitPerPage) async {
    try {
      final response = await api.fetchData(page: page, limit: limitPerPage);
      return PaginationResult.success(response);
    } catch (e) {
      return PaginationResult.failure(e.toString());
    }
  }
}
```

### 2. Initialize PaginationManager

```dart
final paginationManager = PaginationManager<MyData>(
  repository: MyDataRepository(),
  limitPerPage: 20,
);
```

### 3. Use PaginatedManagerList (Recommended)

The simplest way to implement pagination with full state management:

```dart
PaginatedManagerList<MyData>(
  paginationManager: paginationManager,
  itemBuilder: (context, index, items) {
    final item = items[index];
    return ListTile(
      title: Text(item.title),
    );
  },
);
```

That's it! The `PaginatedManagerList` handles everything for you, including:

*   Automatic infinite scrolling
*   Loading states
*   Error handling with customizable retry button
*   Pull-to-refresh
*   Retry mechanisms
*   Empty state handling

#### Customizing PaginatedManagerList

```dart
PaginatedManagerList<MyData>(
  paginationManager: paginationManager,
  itemBuilder: (context, index, items) => MyItemWidget(item: items[index]),
  // Customization options
  scrollThreshold: 0.8,                    // Trigger pagination at 80% scroll
  showRefreshIndicator: true,              // Enable pull-to-refresh
  showRetryButton: true,                   // Show retry button on errors
  emptyItemsText: 'No items found',        // Custom empty state message
  retryText: 'Try Again',                  // Custom retry button text
  scrollDirection: Axis.vertical,          // Scroll direction
  initialLoadingWidget: MyLoadingWidget(), // Custom loading widget
  loadingPaginationWidget: MyLoadingIndicator(), // Custom pagination loading
  emptyItemsWidget: MyEmptyState(),        // Custom empty state widget
  whenErrMessageFromPagination: (message) {
    // Handle pagination errors
    showSnackBar(message);
  },
  fetchItemsFailureWidget: (errorMessage) {
    // Custom error widget
    return MyErrorWidget(message: errorMessage);
  },
  // Styling
  errorTextStyle: TextStyle(color: Colors.red),
  retryTextStyle: TextStyle(color: Colors.blue),
  retryButtonStyle: ButtonStyle(...),
);
```

### 4. Alternative: Manual Implementation

If you need more control, you can use the `PaginatedList` widget directly:

```dart
PaginatedList<MyData>(
  paginationManager: paginationManager,
  loadingFromPaginationState: false,
  fetchNextPage: () => paginationManager.fetchNextPage(),
  itemBuilder: (context, index, items) {
    final item = items[index];
    return ListTile(
      title: Text(item.title),
    );
  },
  retryText: 'Try Again',
  onRefresh: () async {
    paginationManager.reset();
    await paginationManager.fetchNextPage();
  },
);
```

## 🔍 Search Functionality

### 1. Create a Repository with Search Support

For search functionality, your repository should implement the `PaginatedRepositoryWithSearch` interface:

```dart
/// An interface that extends [PaginatedRepository] and [PaginatedSearchRepository].
abstract class PaginatedRepositoryWithSearch<T>
    implements PaginatedRepository<T>, PaginatedSearchRepository<T> {}

class MyDataRepository implements PaginatedRepositoryWithSearch<MyData> {
  @override
  Future<PaginationResult<MyData>> fetchPaginatedItems(int page, int limitPerPage) async {
    // Existing pagination implementation
  }

  @override
  Future<PaginationResult<MyData>> fetchPaginatedSearchItems(
    {required String keyword, required int page, required int limitPerPage}
  ) async {
    try {
      final response = await api.searchData(
        query: keyword, 
        page: page, 
        limit: limitPerPage
      );
      return PaginationResult.success(response.data, hasMore: response.hasMore);
    } catch (e) {
      return PaginationResult.failure(e.toString());
    }
  }
}
```

This interface requires implementing two methods:
- `fetchPaginatedItems(int page, int limitPerPage)` - For regular pagination
- `fetchPaginatedSearchItems(int page, int limitPerPage, String keyword)` - For search-based pagination

### 2. Initialize PaginationManagerWithSearch

Use `PaginationManagerWithSearch` to manage both regular and search pagination:

```dart
/// A class that holds a [PaginationManager] and a [PaginationSearchManager].
///
/// This class is used to manage pagination and search functionality together.
class PaginationManagerWithSearch<T> {
  /// The Interface for fetching paginated items from a repository.
  final PaginatedRepositoryWithSearch<T> repositoryWithSearch;

  /// Items per page for regular pagination.
  final int limitPerPage;

  /// Items per page for search results.
  final int limitPerPageInSearch;

  /// The [PaginationManager] instance for regular pagination.
  late PaginationManager<T> paginationManager;

  /// The [PaginationSearchManager] instance for search-based pagination.
  late PaginationSearchManager<T> paginationSearchManager;

  PaginationManagerWithSearch({
    required this.repositoryWithSearch,
    this.limitPerPage = 20,
    this.limitPerPageInSearch = 20,
  }) {
    paginationManager = PaginationManager<T>(
      repository: repositoryWithSearch, 
      limitPerPage: limitPerPage
    );
    
    paginationSearchManager = PaginationSearchManager<T>(
      repository: repositoryWithSearch, 
      limitPerPage: limitPerPageInSearch
    );
  }
}

// Example Initialization
final paginationManagerWithSearch = PaginationManagerWithSearch<MyData>(
  repositoryWithSearch: MyDataRepository(),
  limitPerPage: 20,
  limitPerPageInSearch: 15, // Optional: different limit for search
);
```

### 3. Use PaginatedManagerListWithSearchManager (Recommended for Search)

This is the most powerful way to implement pagination with search functionality, integrating with `PaginationManagerCubitWithSearch`.

#### Key Features:
- **Lazy loading**: Automatically fetches more items as the user scrolls near the bottom of the list
- **Search integration**: implement pagination with search functionality
- **Customizable UI**: Customize error messages, empty item states, and loading indicators
- **Error handling**: Displays error messages with optional retry buttons for both pagination and search
- **Refresh and retry**: Supports pull-to-refresh functionality for both regular and search modes
- **Flexible**: Supports horizontal and vertical scrolling, and enables custom behavior for loading, empty state, and error states
- **ValueNotifier integration**: Uses `CustomValueNotifierListener` for efficient search input handling

#### Basic Usage:

```dart
class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  late ValueNotifier<String> searchNotifier;
  late PaginationManagerWithSearch<MyData> paginationManagerWithSearch;

  @override
  void initState() {
    super.initState();
    searchNotifier = ValueNotifier<String>('');
    paginationManagerWithSearch = PaginationManagerWithSearch<MyData>(
      repositoryWithSearch: MyDataRepository(),
    );
  }

  @override
  void dispose() {
    searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Data with Search')),
      body: Column(
        children: [
          // Custom Search Field
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...', 
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchNotifier.value = value; // Triggers search automatically
              },
            ),
          ),
          
          // Paginated List with Search
          Expanded(
            child: PaginatedManagerListWithSearchManager<MyData>(
              paginationManagerWithSearch: paginationManagerWithSearch,
              searchValueNotifier: searchNotifier,
              itemBuilder: (context, index, items) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                );
              },
              onSearchChanged: (query) {
                print('Search query: $query');
                // Add analytics or other side effects here
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Advanced Customization:

```dart
PaginatedManagerListWithSearchManager<MyData>(
  paginationManagerWithSearch: paginationManagerWithSearch,
  searchValueNotifier: searchNotifier,
  itemBuilder: (context, index, items) => MyItemWidget(item: items[index]),
  
  // Search-specific customization
  onSearchChanged: (query) {
    // Handle search query changes
    analytics.trackSearch(query);
  },
  
  // Refresh and retry options
  showRefreshIndicator: true,              // Enable pull-to-refresh for pagination
  showRefreshIndicatorForSearch: true,     // Enable pull-to-refresh for search
  showRetryButton: true,                   // Show retry button for pagination errors
  showRetryButtonForSearch: true,          // Show retry button for search errors
  
  // Customization options
  scrollThreshold: 0.8,                    // Trigger pagination at 80% scroll
  emptyItemsText: 'No items found',        // Custom empty state message
  retryText: 'Try Again',                  // Custom retry button text
  scrollDirection: Axis.vertical,          // Scroll direction
  
  // Custom widgets
  initialLoadingWidget: MyLoadingWidget(), // Custom initial loading widget
  loadingPaginationWidget: MyLoadingIndicator(), // Custom pagination loading
  emptyItemsWidget: MyEmptyState(),        // Custom empty state widget
  
  // Error handling
  whenErrMessageFromPagination: (message) {
    // Handle pagination errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pagination Error: $message')),
    );
  },
  fetchItemsFailureWidget: (errorMessage) {
    // Custom error widget
    return MyErrorWidget(message: errorMessage);
  },
  
  // Styling
  errorTextStyle: TextStyle(color: Colors.red),
  retryTextStyle: TextStyle(color: Colors.blue),
  retryButtonStyle: ButtonStyle(...),
);
```

### 4. Alternative: Manual Search Implementation with PaginatedListWithSearchManager

If you need more granular control over the UI and state management for search, you can use the `PaginatedListWithSearchManager` widget directly. This widget is designed to display a paginated list with integrated search input capabilities and is used internally by `PaginatedManagerListWithSearchManager`.

```dart
PaginatedListWithSearchManager<MyData>(
  paginationManagerWithSearch: paginationManagerWithSearch,
  itemBuilder: (context, index, items) => MyItemWidget(items[index]),
  fetchNextPage: () => cubit.fetchNextPage(),
  fetchNextPageForSearch: () => cubit.fetchNextPageforCurrentSearchKeyword(),
  loadingFromPaginationState: state is LoadingFromPagination,
  
  // Optional callbacks
  onRefresh: () => cubit.fetchInitialItems(),
  onRefreshForSearch: () => cubit.searchItems(currentKeyword),
  onRetry: () => cubit.fetchInitialItems(),
  onRetryForSearch: () => cubit.searchItems(currentKeyword),
  
  // Customization
  emptyItemsText: 'No items available',
  scrollThreshold: 0.9,
  shrinkWrap: false,
  scrollDirection: Axis.vertical,
)
```

## 📖 API Reference

### PaginatedManagerList

| Property | Type | Description |
| --- | --- | --- |
| paginationManager | PaginationManager | Required - Manager for pagination logic |
| itemBuilder | Widget? Function(BuildContext, int, List) | Required - Builder for list items |
| scrollThreshold | double | Threshold to trigger pagination (0.0 to 1.0) |
| showRefreshIndicator | bool | Enable/disable pull-to-refresh |
| showRetryButton | bool | Show/hide retry button on errors |
| emptyItemsText | String | Text for empty state |
| retryText | String | Text for retry button |
| loadingPaginationWidget | Widget? | Custom loading indicator |
| whenErrMessageFromPagination | Function(String)? | Error handler for pagination |
| fetchItemsFailureWidget | Widget Function(String)? | Custom error widget builder |
| errorTextStyle | TextStyle? | Style for error messages |
| retryTextStyle | TextStyle? | Style for retry button text |
| retryButtonStyle | ButtonStyle? | Style for retry button |

### PaginationManager

| Property | Type | Description |
| --- | --- | --- |
| repository | PaginatedRepository | Repository for fetching data |
| limitPerPage | int | Items per page |
| items | List | Current items list |
| hasMore | bool | More items available |
| isLoading | bool | Loading state |

### PaginatedRepositoryWithSearch

An interface that extends both `PaginatedRepository` and `PaginatedSearchRepository`:

| Property | Type | Description |
|----------|------|-------------|
| `fetchPaginatedItems` | `Future<PaginationResult<T>> Function(int, int)` | Fetch paginated items for regular pagination |
| `fetchPaginatedSearchItems` | `Future<PaginationResult<T>> Function(int, int, String)` | Fetch paginated search results |

### PaginationManagerWithSearch

| Property | Type | Description |
|----------|------|-------------|
| `repositoryWithSearch` | `PaginatedRepositoryWithSearch<T>` | Repository for fetching data |
| `limitPerPage` | `int` | Items per page for regular pagination |
| `limitPerPageInSearch` | `int` | Items per page for search results |
| `paginationManager` | `PaginationManager<T>` | Manager for regular pagination |
| `paginationSearchManager` | `PaginationSearchManager<T>` | Manager for search-based pagination |

### PaginatedManagerListWithSearchManager

| Property | Type | Description |
|----------|------|-------------|
| `paginationManagerWithSearch` | `PaginationManagerWithSearch<T>` | **Required** - Manager for pagination and search logic |
| `searchValueNotifier` | `ValueNotifier<String>` | **Required** - ValueNotifier for search input |
| `itemBuilder` | `Widget? Function(BuildContext, int, List<T>)` | **Required** - Builder for list items |
| `onSearchChanged` | `void Function(String)?` | Callback when search query changes |
| `scrollThreshold` | `double` | Threshold to trigger pagination (0.0 to 1.0) |
| `showRefreshIndicator` | `bool` | Enable/disable pull-to-refresh for pagination |
| `showRefreshIndicatorForSearch` | `bool` | Enable/disable pull-to-refresh for search |
| `showRetryButton` | `bool` | Show/hide retry button for pagination errors |
| `showRetryButtonForSearch` | `bool` | Show/hide retry button for search errors |
| `emptyItemsText` | `String` | Text for empty state |
| `retryText` | `String` | Text for retry button |
| `loadingPaginationWidget` | `Widget?` | Custom loading indicator for pagination |
| `emptyItemsWidget` | `Widget?` | Custom empty state widget |
| `initialLoadingWidget` | `Widget` | Custom initial loading widget |
| `whenErrMessageFromPagination` | `Function(String)?` | Error handler for pagination |
| `fetchItemsFailureWidget` | `Widget Function(String)?` | Custom error widget builder |
| `errorTextStyle` | `TextStyle?` | Style for error messages |
| `retryTextStyle` | `TextStyle?` | Style for retry button text |
| `retryButtonStyle` | `ButtonStyle?` | Style for retry button |

### PaginatedListWithSearchManager

| Property | Type | Description |
|----------|------|-------------|
| `paginationManagerWithSearch` | `PaginationManagerWithSearch<T>` | **Required** - Manager containing pagination state |
| `itemBuilder` | `Widget? Function(BuildContext, int, List<T>)` | **Required** - Builder for list items |
| `fetchNextPage` | `VoidCallback` | **Required** - Callback for regular pagination |
| `fetchNextPageForSearch` | `VoidCallback` | **Required** - Callback for search pagination |
| `loadingFromPaginationState` | `bool` | **Required** - Whether pagination is loading |
| `onRefresh` | `Future<void> Function()?` | Callback for pull-to-refresh (pagination) |
| `onRefreshForSearch` | `Future<void> Function()?` | Callback for pull-to-refresh (search) |
| `onRetry` | `void Function()?` | Callback for retry (pagination) |
| `onRetryForSearch` | `void Function()?` | Callback for retry (search) |
| `emptyItemsText` | `String` | Text for empty state |
| `scrollThreshold` | `double` | Threshold to trigger pagination (0.0 to 1.0) |
| `shrinkWrap` | `bool` | Whether list should shrink-wrap content |
| `scrollDirection` | `Axis` | Scroll direction (vertical/horizontal) |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.