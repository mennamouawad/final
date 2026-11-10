import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/bookmark_store.dart';
import '../services/yts_movie_service.dart';
import '../widgets/movie_poster.dart';
import 'movie_details_screen.dart';

/// Two tabs: Favorites and Watchlist. Both persist per user with Firestore.
class SavedMoviesScreen extends StatelessWidget {
  final YtsMovieService movieService;
  final BookmarkStore bookmarks;

  const SavedMoviesScreen({
    super.key,
    required this.movieService,
    required this.bookmarks,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Movies'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            Tab(icon: Icon(Icons.bookmark), text: 'Watchlist'),
          ]),
        ),
        body: TabBarView(children: [
          _SavedList(
            type: BookmarkType.favorites,
            bookmarks: bookmarks,
            movieService: movieService,
          ),
          _SavedList(
            type: BookmarkType.watchlist,
            bookmarks: bookmarks,
            movieService: movieService,
          ),
        ]),
      ),
    );
  }
}

class _SavedList extends StatefulWidget {
  final BookmarkType type;
  final BookmarkStore bookmarks;
  final YtsMovieService movieService;

  const _SavedList({
    required this.type,
    required this.bookmarks,
    required this.movieService,
  });

  @override
  State<_SavedList> createState() => _SavedListState();
}

class _SavedListState extends State<_SavedList> {
  late Stream<List<Movie>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.bookmarks.watchMovies(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Movie>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load saved movies: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final movies = snapshot.data!;
        if (movies.isEmpty) {
          return Center(
            child: Text(widget.type == BookmarkType.favorites
                ? 'No favorite movies yet. Tap a heart on Movie Details.'
                : 'Your watchlist is empty. Save movies to watch later.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: MoviePoster(url: movie.posterUrl, width: 64, height: 90),
                title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('⭐ ${movie.rating.toStringAsFixed(1)}  •  ${movie.year}'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MovieDetailsScreen(
                    movieId: movie.id,
                    movieService: widget.movieService,
                    bookmarks: widget.bookmarks,
                  ),
                )),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    try {
                      await widget.bookmarks.remove(movie.id, widget.type);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not remove movie: $e')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
