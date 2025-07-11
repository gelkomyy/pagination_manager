// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:pagination_manager/pagination_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Manager Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Example data model
class Post {
  final int id;
  final String title;
  final String body;
  final String category;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      category: json['category'] ?? 'General',
    );
  }
}

class PostsRepository implements PaginatedRepository<Post> {
  @override
  Future<PaginationResult<Post>> fetchPaginatedItems(
      int page, int limitPerPage) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));
      // Calculate start and end indices for pagination
      final startIndex = (page - 1) * limitPerPage;
      final endIndex = startIndex + limitPerPage;
      // Simulate API response with dummy data
      final List<Post> posts = List.generate(
        100,
        (index) => Post(
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'This is the body of post ${index + 1}.',
          category: _getCategory(index),
        ),
      );

      // Simulate pagination logic
      // Slice the list to get the paginated items
      final paginatedPosts = posts.sublist(
        startIndex,
        endIndex > posts.length ? posts.length : endIndex,
      );

      return PaginationResult.success(paginatedPosts);
    } catch (e) {
      //return PaginationResult.failure(e.toString());
      return const PaginationResult.failure('An error while fetching.');
    }
  }

  String _getCategory(int index) {
    final categories = [
      'Technology',
      'Science',
      'Sports',
      'Entertainment',
      'News'
    ];
    return categories[index % categories.length];
  }
}

// NEW: Repository with search support
class PostsRepositoryWithSearch implements PaginatedRepositoryWithSearch<Post> {
  @override
  Future<PaginationResult<Post>> fetchPaginatedItems(
      int page, int limitPerPage) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));
      // Calculate start and end indices for pagination
      final startIndex = (page - 1) * limitPerPage;
      final endIndex = startIndex + limitPerPage;
      // Simulate API response with dummy data
      final List<Post> posts = List.generate(
        100,
        (index) => Post(
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'This is the body of post ${index + 1}.',
          category: _getCategory(index),
        ),
      );

      // Simulate pagination logic
      // Slice the list to get the paginated items
      final paginatedPosts = posts.sublist(
        startIndex,
        endIndex > posts.length ? posts.length : endIndex,
      );

      return PaginationResult.success(paginatedPosts);
    } catch (e) {
      return const PaginationResult.failure('An error while fetching.');
    }
  }

  @override
  Future<PaginationResult<Post>> fetchPaginatedSearchItems(
      {required String keyword,
      required int page,
      required int limitPerPage}) async {
    try {
      // Simulate API delay for search
      await Future.delayed(const Duration(milliseconds: 800));

      if (keyword.trim().isEmpty) {
        return PaginationResult.success([]);
      }

      // Generate all posts for search
      final List<Post> allPosts = List.generate(
        100,
        (index) => Post(
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'This is the body of post ${index + 1}.',
          category: _getCategory(index),
        ),
      );

      // Filter posts based on keyword (search in title, body, and category)
      final filteredPosts = allPosts.where((post) {
        final searchTerm = keyword.toLowerCase();
        return post.title.toLowerCase().contains(searchTerm) ||
            post.body.toLowerCase().contains(searchTerm) ||
            post.category.toLowerCase().contains(searchTerm);
      }).toList();

      // Calculate start and end indices for search pagination
      final startIndex = (page - 1) * limitPerPage;
      final endIndex = startIndex + limitPerPage;

      if (startIndex >= filteredPosts.length) {
        return PaginationResult.success([]);
      }

      final paginatedSearchResults = filteredPosts.sublist(
        startIndex,
        endIndex > filteredPosts.length ? filteredPosts.length : endIndex,
      );

      return PaginationResult.success(paginatedSearchResults);
    } catch (e) {
      return const PaginationResult.failure('Search error occurred.');
    }
  }

  String _getCategory(int index) {
    final categories = [
      'Technology',
      'Science',
      'Sports',
      'Entertainment',
      'News'
    ];
    return categories[index % categories.length];
  }
}

// Home screen to navigate between examples
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Manager Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose an example to explore:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Original PaginatedManagerList example
            Card(
              child: ListTile(
                leading: const Icon(Icons.list, color: Colors.blue),
                title: const Text('Original Pagination'),
                subtitle:
                    const Text('PaginatedManagerList with PaginationManager'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // NEW: PaginatedManagerListWithSearchManager example
            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: Colors.green),
                title: const Text('Pagination with Search'),
                subtitle: const Text(
                    'PaginatedManagerListWithSearchManager with search functionality'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostListWithSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // NEW: Manual PaginatedListWithSearchManager example
            Card(
              child: ListTile(
                leading: const Icon(Icons.build, color: Colors.orange),
                title: const Text('Manual Search Implementation'),
                subtitle: const Text(
                    'PaginatedListWithSearchManager with manual control'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualSearchScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 20),

            const Text(
              'Features Demonstrated:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text('• Original PaginatedManagerList (unchanged)'),
            const Text('• NEW: PaginatedRepositoryWithSearch interface'),
            const Text('• NEW: PaginationManagerWithSearch class'),
            const Text('• NEW: PaginatedManagerListWithSearchManager widget'),
            const Text('• NEW: PaginatedListWithSearchManager widget'),
            const Text('• Search functionality with debouncing'),
            const Text('• Custom ValueNotifier integration'),
            const Text('• Seamless switching between pagination and search'),
          ],
        ),
      ),
    );
  }
}

// Original PostListScreen (unchanged)
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final PaginationManager<Post> _paginationManager;

  @override
  void initState() {
    super.initState();
    _paginationManager = PaginationManager<Post>(
      repository: PostsRepository(),
      limitPerPage: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (Original)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PaginatedManagerList<Post>(
        paginationManager: _paginationManager,
        itemBuilder: (context, index, items) {
          final post = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  '${post.id}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        // Customize the pagination experience
        scrollThreshold: 0.8,
        showRefreshIndicator: true,
        emptyItemsText: 'No posts available',
        retryText: 'Try Again',
        // Handle pagination errors
        whenErrMessageFromPagination: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $message')),
          );
        },
      ),
    );
  }
}

// NEW: PostListWithSearchScreen using PaginatedManagerListWithSearchManager
class PostListWithSearchScreen extends StatefulWidget {
  const PostListWithSearchScreen({super.key});

  @override
  State<PostListWithSearchScreen> createState() =>
      _PostListWithSearchScreenState();
}

class _PostListWithSearchScreenState extends State<PostListWithSearchScreen> {
  late ValueNotifier<String> searchNotifier;
  late PaginationManagerWithSearch<Post> paginationManagerWithSearch;

  @override
  void initState() {
    super.initState();
    searchNotifier = ValueNotifier<String>('');
    paginationManagerWithSearch = PaginationManagerWithSearch<Post>(
      repositoryWithSearch: PostsRepositoryWithSearch(),
      limitPerPage: 10,
      limitPerPageInSearch: 8,
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
      appBar: AppBar(
        title: const Text('Posts with Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Custom Search Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search posts by title, content, or category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<String>(
                  valueListenable: searchNotifier,
                  builder: (context, value, child) {
                    return value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchNotifier.value = '';
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                searchNotifier.value = value;
              },
            ),
          ),

          // Search Status Indicator
          ValueListenableBuilder<String>(
            valueListenable: searchNotifier,
            builder: (context, searchValue, child) {
              if (searchValue.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue[50],
                  child: Text(
                    'Searching for: "$searchValue"',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // NEW: PaginatedManagerListWithSearchManager
          Expanded(
            child: PaginatedManagerListWithSearchManager<Post>(
              paginationManagerWithSearch: paginationManagerWithSearch,
              searchValueNotifier: searchNotifier,
              itemBuilder: (context, index, items) {
                final post = items[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${post.id}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            post.category,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              emptyItemsText: 'No posts available',
              emptyItemsWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No posts found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try adjusting your search terms',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              initialLoadingWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading posts...'),
                  ],
                ),
              ),
              loadingPaginationWidget: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              whenErrMessageFromPagination: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pagination Error: $message'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              onSearchChanged: (query) {
                debugPrint('Search query changed: "$query"');
                // You can add analytics tracking or other side effects here
              },
              scrollThreshold: 0.8,
              showRefreshIndicator: true,
              showRetryButton: true,
              showRefreshIndicatorForSearch: true,
              showRetryButtonForSearch: true,
              errorTextStyle: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              retryTextStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Manual implementation using PaginatedListWithSearchManager
class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  late PaginationManagerWithSearch<Post> paginationManagerWithSearch;
  bool isLoading = false;
  String currentSearchKeyword = '';

  @override
  void initState() {
    super.initState();
    paginationManagerWithSearch = PaginationManagerWithSearch<Post>(
      repositoryWithSearch: PostsRepositoryWithSearch(),
      limitPerPage: 10,
      limitPerPageInSearch: 8,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await paginationManagerWithSearch.paginationManager.fetchNextPage();
    setState(() => isLoading = false);
  }

  Future<void> _performSearch(String keyword) async {
    setState(() {
      isLoading = true;
      currentSearchKeyword = keyword;
    });

    if (keyword.isEmpty) {
      // Switch back to regular pagination
      paginationManagerWithSearch.paginationManager.reset();
      await paginationManagerWithSearch.paginationManager.fetchNextPage();
    } else {
      // Perform search
      paginationManagerWithSearch.paginationSearchManager.changeCurrentKeyword =
          keyword;
      await paginationManagerWithSearch.paginationSearchManager
          .fetchNextPageforCurrentSearchKeyword();
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchNextPage() async {
    if (currentSearchKeyword.isEmpty) {
      await paginationManagerWithSearch.paginationManager.fetchNextPage();
    } else {
      await paginationManagerWithSearch.paginationSearchManager
          .fetchNextPageforCurrentSearchKeyword();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFromSearch = currentSearchKeyword.isNotEmpty;
    final items = isFromSearch
        ? paginationManagerWithSearch.paginationSearchManager.items
        : paginationManagerWithSearch.paginationManager.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Search Implementation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search posts manually...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                // Debounce search calls
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _performSearch(value);
                  }
                });
              },
            ),
          ),

          // Status indicator
          if (currentSearchKeyword.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[50],
              child: Text(
                'Manual search mode: "$currentSearchKeyword"',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // NEW: PaginatedListWithSearchManager (manual control)
          Expanded(
            child: isLoading && items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading posts...'),
                      ],
                    ),
                  )
                : PaginatedListWithSearchManager<Post>(
                    paginationManagerWithSearch: paginationManagerWithSearch,
                    itemBuilder: (context, index, items) {
                      final post = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isFromSearch
                                ? Colors.orange
                                : Theme.of(context).primaryColor,
                            child: Text(
                              '${post.id}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          title: Text(
                            post.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      post.category,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isFromSearch) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'SEARCH',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    fetchNextPage: _fetchNextPage,
                    fetchNextPageForSearch: _fetchNextPage,
                    loadingFromPaginationState: isLoading,
                    onRefresh: () async {
                      if (isFromSearch) {
                        await _performSearch(currentSearchKeyword);
                      } else {
                        paginationManagerWithSearch.paginationManager.reset();
                        await _loadInitialData();
                      }
                    },
                    onRefreshForSearch: () async {
                      await _performSearch(currentSearchKeyword);
                    },
                    onRetry: () async {
                      if (isFromSearch) {
                        await _performSearch(currentSearchKeyword);
                      } else {
                        await _loadInitialData();
                      }
                    },
                    onRetryForSearch: () async {
                      await _performSearch(currentSearchKeyword);
                    },
                    emptyItemsText: isFromSearch
                        ? 'No search results found'
                        : 'No posts available',
                    scrollThreshold: 0.9,
                  ),
          ),
        ],
      ),
    );
  }
}
