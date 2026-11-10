import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../services/bookmark_store.dart';
import '../services/yts_movie_service.dart';
import '../widgets/movie_poster.dart';

/// Your reusable Movie Details screen. Member 2 only needs to pass movieId.
class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final YtsMovieService movieService;
  final BookmarkStore bookmarks;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    required this.movieService,
    required this.bookmarks,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Movie> _movieFuture;
  late Stream<Set<int>> _favoriteIds;
  late Stream<Set<int>> _watchlistIds;

  @override
  void initState() {
    super.initState();
    _movieFuture = widget.movieService.getMovie(widget.movieId);
    _favoriteIds = widget.bookmarks.watchIds(BookmarkType.favorites);
    _watchlistIds = widget.bookmarks.watchIds(BookmarkType.watchlist);
  }

  void _retry() {
    setState(() {
      _movieFuture = widget.movieService.getMovie(widget.movieId);
    });
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !['http', 'https'].contains(uri.scheme)) {
      _message('Invalid link');
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message('Could not open link');
      }
    } catch (_) {
      _message('Could not open link');
    }
  }

  Widget _bookmarkButton(Movie movie, BookmarkType type) {
    final isFavorite = type == BookmarkType.favorites;
    return StreamBuilder<Set<int>>(
      stream: isFavorite ? _favoriteIds : _watchlistIds,
      builder: (context, snapshot) {
        final selected = snapshot.data?.contains(movie.id) ?? false;
        return OutlinedButton.icon(
          onPressed: !snapshot.hasData || snapshot.hasError
              ? null
              : () async {
                  try {
                    await widget.bookmarks.toggle(movie, type);
                  } catch (e) {
                    _message('Could not update saved movies: $e');
                  }
                },
          icon: Icon(isFavorite
              ? (selected ? Icons.favorite : Icons.favorite_border)
              : (selected ? Icons.bookmark : Icons.bookmark_border)),
          label: Text(isFavorite
              ? (selected ? 'Favorited' : 'Add to Favorites')
              : (selected ? 'In Watchlist' : 'Watch Later')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Details')),
      body: FutureBuilder<Movie>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48),
                    const SizedBox(height: 16),
                    const Text('Could not load movie. Check the API or internet.'),
                    const SizedBox(height: 8),
                    SelectableText('${snapshot.error ?? 'Unknown error'}'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final movie = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: MoviePoster(url: movie.posterUrl, width: 190, height: 275)),
              const SizedBox(height: 18),
              Text(
                movie.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 7,
                children: [
                  _info(Icons.star, movie.rating.toStringAsFixed(1)),
                  _info(Icons.calendar_month, movie.year == 0 ? '—' : '${movie.year}'),
                  _info(Icons.timer_outlined, movie.runtime == 0 ? '—' : '${movie.runtime} min'),
                ],
              ),
              if (movie.genres.isNotEmpty) ...[
                const SizedBox(height: 14),
                Center(child: Text(movie.genres.join(' • '), textAlign: TextAlign.center)),
              ],
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _bookmarkButton(movie, BookmarkType.favorites),
                  _bookmarkButton(movie, BookmarkType.watchlist),
                ],
              ),
              const SizedBox(height: 20),
              if (movie.description.isNotEmpty) ...[
                _heading('Story'),
                Text(movie.description),
                const SizedBox(height: 20),
              ],
              if (movie.trailerCode.isNotEmpty) ...[
                _heading('Trailer'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch trailer on YouTube'),
                    onPressed: () => _openExternal(
                      'https://www.youtube.com/watch?v=${Uri.encodeComponent(movie.trailerCode)}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _heading('Cast'),
              if (movie.cast.isEmpty)
                const Text('Cast information is not available for this movie.')
              else
                ...movie.cast.take(10).map(
                  (actor) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: actor.imageUrl.isEmpty
                          ? const Icon(Icons.person)
                          : ClipOval(
                              child: Image.network(
                                actor.imageUrl,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.person),
                              ),
                            ),
                    ),
                    title: Text(actor.name),
                    subtitle: actor.character.isEmpty
                        ? null
                        : Text('as ${actor.character}'),
                  ),
                ),
              const SizedBox(height: 20),
              _heading('Available Formats / Torrents'),
              if (movie.torrents.isEmpty)
                const Text('No formats are returned by the API.')
              else
                ...movie.torrents.map(
                  (torrent) => Card(
                    child: ListTile(
                      title: Text('${torrent.quality} ${torrent.type}'.trim()),
                      subtitle: Text(torrent.size),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: torrent.url.isEmpty
                          ? null
                          : () => _openExternal(torrent.url),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      );

  Widget _info(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(text),
        ],
      );
}
