import '../models/movie.dart';
import 'yts_movie_service.dart';

/// Offline UI preview only: MOCK data, not an API success test.
class PreviewMovieService extends YtsMovieService {
  @override
  Future<Movie> getMovie(int movieId) async => const Movie(
        id: 99999,
        title: 'Sample Movie — UI Preview Only',
        year: 2026,
        rating: 8.2,
        description:
            'This is sample text for testing the screen layout without internet. '
            'Replace this with the movie returned by the YTS API.',
        genres: ['Drama', 'Adventure'],
        runtime: 116,
        cast: [
          CastMember(name: 'Sample Actor One', character: 'Main character'),
          CastMember(name: 'Sample Actor Two', character: 'Supporting character'),
        ],
        torrents: [
          MovieTorrent(quality: '1080p', type: 'WEB', size: '1.8 GB'),
        ],
      );
}
