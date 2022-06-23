// Packages
import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'https://api.themoviedb.org/3/';
const baseImageUrl = 'https://image.tmdb.org/t/p/';
const apiKey = '046fb33b9ccef98df04c2d9d524200df';

class TmdbDataProvider {
  Future<Map<String, dynamic>> fetchMovies({
    required int page,
    String? query,
    String? orderBy,
    String? category,
    int? voteCountMin,
    String? releaseDateMin,
    String? releaseDateMax,
    String? genres,
  }) async {
    page++;

    String url = (query != '' && query != null)
        ? '${baseUrl}search/movie?api_key=$apiKey&query=$query&page=$page'
        : '${baseUrl}discover/movie?api_key=$apiKey&page=$page&vote_count.gte=$voteCountMin'
            '&sort_by=$category.$orderBy&primary_release_date.gte=$releaseDateMin'
            '&primary_release_date.lte=$releaseDateMax&with_genres=$genres';

    var response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchSingleMovie(num movieId) async {
    var response =
        await http.get(Uri.parse('${baseUrl}movie/$movieId?api_key=$apiKey'));
    return jsonDecode(response.body);
  }

  Future<String> getGuestSessionId() async {
    var response = await http.get(
        Uri.parse('$baseUrl/authentication/guest_session/new?api_key=$apiKey'));
    var decodedJson = jsonDecode(response.body);

    return decodedJson['guest_session_id'];
  }

  void rateMovie({
    required String guestId,
    required num rating,
    required num movieId,
  }) {
    http.post(
      Uri.parse(
          '${baseUrl}movie/$movieId/rating?api_key=$apiKey&guest_session_id=$guestId'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'value': rating}),
    );
  }
}
