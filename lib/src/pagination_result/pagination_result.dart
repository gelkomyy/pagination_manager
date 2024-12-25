import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_result.freezed.dart';

@Freezed()

///  A class that represents the result of a pagination operation.
abstract class PaginationResult<T> with _$PaginationResult<T> {
  /// A class that represents the success result of a pagination operation.
  const factory PaginationResult.success(List<T> items) = Success<T>;

  /// A class that represents the failure result of a pagination operation.
  const factory PaginationResult.failure(String message) = Failure<T>;
}
