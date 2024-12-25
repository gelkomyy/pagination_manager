import 'package:pagination_manager/pagination_manager.dart';

/// An interface that extends [PaginatedRepository] and [PaginatedSearchRepository].
abstract class PaginatedRepositoryWithSearch<T>
    implements PaginatedRepository<T>, PaginatedSearchRepository<T> {}
