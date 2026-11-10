import 'package:flutter/material.dart';

import 'member3/models/movie.dart';
import 'member3/screens/movie_details_screen.dart';
import 'member3/services/preview_movie_service.dart';
import 'member3/widgets/movie_poster.dart';
import 'member3_bridge.dart';

/// Temporary integration hub. It can open real YTS details and saved movies
/// while Member 2's Home remains untouched.
class Member3HubScreen extends StatefulWidget {
  const Member3HubScreen({super.key});

  @override
  State<Member3HubScreen> createState() => _Member3HubScreenState();
}

class _Member3HubScreenState extends State<Member3HubScreen> {
  late Future<List<Movie>> _movies;
  final TextEditingController _movieId = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _movies = Member3Bridge.movieService.listDemoMovies();
  }

  @override
  void dispose() {
    _movieId.dispose();
    super.dispose();
  }

  void _openMovie(int id) {
    Member3Bridge.openDetails(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final cloud = Member3Bridge.isFirebaseReady;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details & My Movies'),
        actions: [
          IconButton(
            tooltip: 'Saved Movies',
            onPressed: () => Member3Bridge.openSavedMovies(context),
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Icon(cloud ? Icons.cloud_done : Icons.cloud_off_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cloud
                      ? 'Signed in: favorites and watchlist use Firebase Firestore.'
                      : 'Demo storage: favorites/watchlist are temporary until team Firebase is configured and the user signs in.'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _movieId,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'YTS Movie ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final id = int.tryParse(_movieId.text.trim());
                if (id == null || id <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid movie ID')),
                  );
                  return;
                }
                _openMovie(id);
              },
              child: const Text('Open'),
            ),
          ]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.favorite_border),
            label: const Text('Open Favorites & Watchlist'),
            onPressed: () => Member3Bridge.openSavedMovies(context),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Offline UI preview'),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => MovieDetailsScreen(
                    movieId: 99999,
                    movieService: PreviewMovieService(),
                    bookmarks: Member3Bridge.bookmarks,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Text('Live movies (YTS API)', style: Theme.of(context).textTheme.titleLarge),
          FutureBuilder<List<Movie>>(
            future: _movies,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Could not load movies. Check the YTS API or internet.'),
                    SelectableText('${snap.error}'),
                    TextButton(
                      onPressed: () => setState(
                        () => _movies = Member3Bridge.movieService.listDemoMovies(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }
              final results = snap.data ?? <Movie>[];
              if (results.isEmpty) return const Text('No movies were returned.');
              return Column(
                children: results.map((movie) => ListTile(
                  leading: MoviePoster(url: movie.posterUrl, width: 52, height: 68),
                  title: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('ID ${movie.id}  •  ★ ${movie.rating}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openMovie(movie.id),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
