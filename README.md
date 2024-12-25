# 📦 Pagination Manager

[![Pub Version](https://img.shields.io/pub/v/pagination_manager)](https://pub.dev/packages/pagination_manager)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful and flexible Flutter package for handling paginated data with built-in state management support. Easily implement infinite scrolling lists with minimal boilerplate code.

## ✨ Features

- 🚀 Easy-to-use pagination management
- 💪 Built-in Bloc/Cubit state management support
- 🎯 Framework-agnostic - works with any state management solution
- 🔄 Pull-to-refresh support
- ⚡ Lazy loading with automatic state management
- 🎨 Customizable loading and error states
- 📱 Responsive and adaptive design

## 📋 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  pagination_manager: ^1.0.0
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
- Automatic infinite scrolling
- Loading states
- Error handling with customizable retry button
- Pull-to-refresh
- Retry mechanisms
- Empty state handling

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

## 📖 API Reference

### PaginatedManagerList

| Property | Type | Description |
|----------|------|-------------|
| paginationManager | PaginationManager<T> | Required - Manager for pagination logic |
| itemBuilder | Widget? Function(BuildContext, int, List<T>) | Required - Builder for list items |
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
|----------|------|-------------|
| repository | PaginatedRepository<T> | Repository for fetching data |
| limitPerPage | int | Items per page |
| items | List<T> | Current items list |
| hasMore | bool | More items available |
| isLoading | bool | Loading state |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.