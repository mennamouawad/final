import 'package:flutter/material.dart';
import 'member3/models/movie.dart';
import 'member3/screens/movie_details_screen.dart';
import 'member3/screens/saved_movies_screen.dart';
import 'member3/services/demo_bookmark_store.dart';
import 'member3/services/yts_movie_service.dart';
import 'member3/services/preview_movie_service.dart';
import 'member3/widgets/movie_poster.dart';

/// Run JUST Member 3 without waiting for Member 2:
/// flutter run -t lib/member3_demo_main.dart
/// Test bookmarks here with temporary, in-memory storage.
void main() {
  runApp(const Member3DemoApp());
}

class Member3DemoApp extends StatefulWidget {
  const Member3DemoApp({super.key});

  @override
  State<Member3DemoApp> createState() => _Member3DemoAppState();
}

class _Member3DemoAppState extends State<Member3DemoApp> {
  final _movieService = YtsMovieService();
  final _bookmarks = DemoBookmarkStore();

  @override
  void dispose() {
    _bookmarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Member 3 Independent Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: _DemoLauncher(movieService: _movieService, bookmarks: _bookmarks),
    );
  }
}

class _DemoLauncher extends StatefulWidget {
  final YtsMovieService movieService;
  final DemoBookmarkStore bookmarks;
  const _DemoLauncher({required this.movieService, required this.bookmarks});

  @override
  State<_DemoLauncher> createState() => _DemoLauncherState();
}

class _DemoLauncherState extends State<_DemoLauncher> {
  late Future<List<Movie>> _movieList;
  final _idController = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _movieList = widget.movieService.listDemoMovies();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _showDetails(int id) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MovieDetailsScreen(
        movieId: id,
        movieService: widget.movieService,
        bookmarks: widget.bookmarks,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member 3 — Independent Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('This temporary launcher replaces Member 2\'s Home ONLY for testing.'),
          const SizedBox(height: 8),
          const Text('Saved movies here are temporary. Use FirestoreBookmarkStore after team Firebase integration.'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'YTS movie ID',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final id = int.tryParse(_idController.text);
                if (id != null && id > 0) {
                  _showDetails(id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid numeric movie ID')),
                  );
                }
              },
              child: const Text('Open'),
            ),
          ]),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            icon: const Icon(Icons.favorite),
            label: const Text('Open Favorites / Watchlist'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SavedMoviesScreen(
                movieService: widget.movieService,
                bookmarks: widget.bookmarks,
              ),
            )),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Offline UI preview (sample data)'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(
                movieId: 99999,
                movieService: PreviewMovieService(),
                bookmarks: widget.bookmarks,
              ),
            )),
          ),
          const SizedBox(height: 22),
          Text('Live YTS movies (temporary test list)',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<Movie>>(
            future: _movieList,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Could not reach YTS API. Check internet or current API host.'),
                    SelectableText('${snapshot.error}'),
                    OutlinedButton(
                      onPressed: () => setState(
                          () => _movieList = widget.movieService.listDemoMovies()),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }
              final movies = snapshot.data ?? [];
              if (movies.isEmpty) return const Text('No movies returned.');
              return Column(
                children: movies.map((movie) => ListTile(
                      leading: MoviePoster(
                          url: movie.posterUrl, width: 56, height: 74),
                      title: Text(movie.title),
                      subtitle: Text('ID ${movie.id} • ⭐ ${movie.rating}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showDetails(movie.id),
                    )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
