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
      home: const PostListScreen(),
    );
  }
}

// Example data model
class Post {
  final int id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

// Example repository implementation
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
}

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
        title: const Text('Posts'),
      ),
      body: PaginatedManagerList<Post>(
        paginationManager: _paginationManager,
        itemBuilder: (context, index, items) {
          final post = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
