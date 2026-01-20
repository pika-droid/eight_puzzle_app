class ServerException implements Exception {}

class CacheException implements Exception {}

class UnsolvablePuzzleException implements Exception {
  final String message;
  UnsolvablePuzzleException([
    this.message = 'The puzzle configuration is unsolvable.',
  ]);
}
