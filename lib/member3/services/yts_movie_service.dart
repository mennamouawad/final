import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// Uses the host provided in the course brief. If YTS changes its host,
/// update this ONE place after checking with your team's API owner.
class YtsMovieService {
  final String baseUrl;
  final http.Client _client;

  YtsMovieService({
    this.baseUrl = 'https://yts.lt/api/v2',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(
    String endpoint,
    Map<String, String> params,
  ) async {
    final uri = Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: params);
    final response = await _client.get(uri).timeout(
      const Duration(seconds: 18),
    );
    if (response.statusCode != 200) {
      throw Exception('API HTTP error: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['status'] != 'ok') {
      throw Exception('YTS API returned an error or unexpected data');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('YTS response has no data object');
    }
    return data;
  }

  Future<Movie> getMovie(int movieId) async {
    final data = await _get('movie_details.json', {
      'movie_id': '$movieId',
      'with_images': 'true',
      'with_cast': 'true',
    });
    if (data['movie'] is! Map) {
      throw Exception('No movie found for ID $movieId');
    }
    return Movie.fromJson(Map<String, dynamic>.from(data['movie'] as Map));
  }

  /// Demo helper only; Member 2 will own the main movie listing.
  Future<List<Movie>> listDemoMovies() async {
    final data = await _get('list_movies.json', {
      'limit': '12',
      'sort_by': 'rating',
      'order_by': 'desc',
    });
    final raw = data['movies'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
        .where((movie) => movie.id > 0)
        .toList();
  }
}
