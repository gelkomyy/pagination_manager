## 1.1.0

*   **New Features:**
    *   **Paginated Search Manager**: Integrated comprehensive search functionality.
    *   **`PaginatedRepositoryWithSearch`**: New interface for repositories supporting both pagination and search.
    *   **`PaginationManagerWithSearch`**: Manages both `PaginationManager` and `PaginationSearchManager` for combined functionality.
    *   **`PaginatedManagerListWithSearchManager`**: High-level widget for easy integration of paginated lists with search.
    *   **`PaginatedListWithSearchManager`**: Lower-level widget for manual control over paginated lists with search.
    *   **Intelligent Debouncing**: Optimizes API calls for search queries.
    *   **Seamless Mode Switching**: Automatically handles transitions between pagination and search modes.
    *   **Enhanced Error Handling**: Specific error handling and retry mechanisms for search operations.
    *   **Flexible Refresh**: Separate pull-to-refresh indicators for pagination and search.

## 1.0.0

*   Initial release
*   Features:
    *   Pagination management with minimal setup
    *   Built-in Bloc/Cubit state management
    *   PaginatedManagerList widget for easy implementation
    *   PaginatedList widget for custom implementations
    *   Customizable loading and error states
    *   Pull-to-refresh support
    *   Automatic infinite scrolling
    *   Error handling with retry mechanism


