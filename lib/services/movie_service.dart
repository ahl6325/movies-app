import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const _apiKey = '8bb1bc74dbccf6c2a6b98d61291633fd';
  static const _base = 'https://api.themoviedb.org/3';

  static Future<List<Movie>> _fetch(String path, {String mediaType = 'movie', int page = 1}) async {
    final url = Uri.parse('$_base$path?api_key=$_apiKey&language=fr-FR&page=$page');
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((e) => Movie.fromJson(e, mediaType: mediaType))
        .where((m) => m.posterPath != null)
        .toList();
  }

  static Future<List<Movie>> getPopularMovies({int page = 1}) => _fetch('/movie/popular', page: page);
  static Future<List<Movie>> getPopularTV({int page = 1}) => _fetch('/tv/popular', mediaType: 'tv', page: page);
  static Future<List<Movie>> getTrending({int page = 1}) => _fetch('/trending/all/week', page: page);
}