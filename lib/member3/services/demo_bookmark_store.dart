import 'dart:async';
import '../models/movie.dart';
import 'bookmark_store.dart';

/// Only for independent UI testing. These items DO NOT persist on restart.
class DemoBookmarkStore extends BookmarkStore {
  final Map<BookmarkType, Map<int, Movie>> _movies = {
    BookmarkType.favorites: {},
    BookmarkType.watchlist: {},
  };
  final Map<BookmarkType, StreamController<List<Movie>>> _updates = {
    BookmarkType.favorites: StreamController<List<Movie>>.broadcast(),
    BookmarkType.watchlist: StreamController<List<Movie>>.broadcast(),
  };

  @override
  Stream<List<Movie>> watchMovies(BookmarkType type) async* {
    yield _movies[type]!.values.toList();
    yield* _updates[type]!.stream;
  }

  void _emit(BookmarkType type) {
    _updates[type]!.add(_movies[type]!.values.toList());
  }

  @override
  Future<void> toggle(Movie movie, BookmarkType type) async {
    final selected = _movies[type]!;
    if (selected.containsKey(movie.id)) {
      selected.remove(movie.id);
    } else {
      selected[movie.id] = movie;
    }
    _emit(type);
  }

  @override
  Future<void> remove(int movieId, BookmarkType type) async {
    _movies[type]!.remove(movieId);
    _emit(type);
  }

  void dispose() {
    for (final controller in _updates.values) {
      controller.close();
    }
  }
}
