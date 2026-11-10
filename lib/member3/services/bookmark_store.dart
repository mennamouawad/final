import '../models/movie.dart';

enum BookmarkType { favorites, watchlist }

/// A common interface makes it possible to test without Firebase, and
/// then switch to the real Firestore account without editing the screens.
abstract class BookmarkStore {
  Stream<List<Movie>> watchMovies(BookmarkType type);
  Stream<Set<int>> watchIds(BookmarkType type) =>
      watchMovies(type).map((movies) => movies.map((m) => m.id).toSet());
  Future<void> toggle(Movie movie, BookmarkType type);
  Future<void> remove(int movieId, BookmarkType type);
}
