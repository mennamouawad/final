/// Member 3 - YTS movie models.
/// Works with the movie_details and list_movies API responses.
class Movie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final String posterUrl;
  final String backgroundUrl;
  final String description;
  final List<String> genres;
  final int runtime;
  final String trailerCode;
  final List<CastMember> cast;
  final List<MovieTorrent> torrents;

  const Movie({
    required this.id,
    required this.title,
    this.year = 0,
    this.rating = 0,
    this.posterUrl = '',
    this.backgroundUrl = '',
    this.description = '',
    this.genres = const [],
    this.runtime = 0,
    this.trailerCode = '',
    this.cast = const [],
    this.torrents = const [],
  });

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double _double(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String _str(dynamic value) => value?.toString() ?? '';

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawCast = json['cast'];
    final rawTorrents = json['torrents'];
    final rawGenres = json['genres'];
    final cover = _str(json['large_cover_image']);
    final mediumCover = _str(json['medium_cover_image']);
    final fullDescription = _str(json['description_full']);
    final altDescription = _str(json['description_intro']);

    return Movie(
      id: _int(json['id']),
      title: _str(json['title_long']).isNotEmpty
          ? _str(json['title_long'])
          : _str(json['title']),
      year: _int(json['year']),
      rating: _double(json['rating']),
      posterUrl: cover.isNotEmpty ? cover : mediumCover,
      backgroundUrl: _str(json['background_image_original']).isNotEmpty
          ? _str(json['background_image_original'])
          : _str(json['background_image']),
      description: fullDescription.isNotEmpty
          ? fullDescription
          : altDescription,
      genres: rawGenres is List
          ? rawGenres.map((e) => _str(e)).toList()
          : const [],
      runtime: _int(json['runtime']),
      trailerCode: _str(json['yt_trailer_code']),
      cast: rawCast is List
          ? rawCast
              .whereType<Map>()
              .map((e) => CastMember.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      torrents: rawTorrents is List
          ? rawTorrents
              .whereType<Map>()
              .map((e) => MovieTorrent.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  /// Only essential fields are stored; reopen a saved movie by its ID.
  Map<String, dynamic> toSavedJson() => {
        'id': id,
        'title': title,
        'year': year,
        'rating': rating,
        'posterUrl': posterUrl,
        'genres': genres,
      };

  factory Movie.fromSavedJson(Map<String, dynamic> json) => Movie(
        id: _int(json['id']),
        title: _str(json['title']),
        year: _int(json['year']),
        rating: _double(json['rating']),
        posterUrl: _str(json['posterUrl']),
        genres: json['genres'] is List
            ? (json['genres'] as List).map((e) => _str(e)).toList()
            : const [],
      );
}

class CastMember {
  final String name;
  final String character;
  final String imageUrl;

  const CastMember({
    required this.name,
    this.character = '',
    this.imageUrl = '',
  });

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        name: json['name']?.toString() ?? '',
        character: json['character_name']?.toString() ?? '',
        imageUrl: json['url_small_image']?.toString() ?? '',
      );
}

class MovieTorrent {
  final String quality;
  final String type;
  final String size;
  final String url;

  const MovieTorrent({
    this.quality = '',
    this.type = '',
    this.size = '',
    this.url = '',
  });

  factory MovieTorrent.fromJson(Map<String, dynamic> json) => MovieTorrent(
        quality: json['quality']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        size: json['size']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );
}
