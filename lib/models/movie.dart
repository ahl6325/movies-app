class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final String mediaType;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    this.mediaType = 'movie',
  });

  factory Movie.fromJson(Map<String, dynamic> json, {String mediaType = 'movie'}) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: json['media_type'] ?? mediaType,
    );
  }

  String get posterUrl => posterPath != null ? 'https://image.tmdb.org/t/p/w342$posterPath'
      : '';
  String get backdropUrl => backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';
}