// Packages
import 'package:cloud_firestore/cloud_firestore.dart';

class MovieResults {
  List<MovieElement>? movies;
  int? page;
  int? totalResults;
  int? totalPages;

  MovieResults({
    this.movies = const [],
    this.page = 0,
    this.totalResults = 0,
    this.totalPages = 0,
  });

  MovieResults.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      movies = <MovieElement>[];
      json['results'].forEach((v) => movies?.add(MovieElement.fromJson(v)));
    }
    page = json['page'];
    totalResults = json['total_results'];
    totalPages = json['total_pages'];
  }
}

class MovieElement {
  int voteCount = 0;
  int id = 0;
  double voteAverage = 0;
  String title = '';
  String? posterPath = '';
  List<int> genreIds = const [];
  String? backdropPath = '';
  String overview = '';
  String releaseDate = '';

  MovieElement({
    this.voteCount = 0,
    this.id = 0,
    this.voteAverage = 0,
    this.title = '',
    this.posterPath = '',
    this.genreIds = const [],
    this.backdropPath = '',
    this.overview = '',
    this.releaseDate = '',
  });

  MovieElement.fromJson(Map<String, dynamic> json) {
    voteCount = json['vote_count'];
    id = json['id'];
    voteAverage =
        (json['vote_average'] != null) ? json['vote_average'].toDouble() : null;
    title = json['title'];
    posterPath = (json['poster_path'] != null)
        ? 'https://image.tmdb.org/t/p/w342/${json['poster_path']}'
        : null;
    genreIds =
        (json['genre_ids'] != null) ? json['genre_ids'].cast<int>() : null;
    backdropPath = (json['backdrop_path'] != null)
        ? 'https://image.tmdb.org/t/p/w400/${json['backdrop_path']}'
        : null;
    overview = json['overview'];
    releaseDate = json['release_date'];
  }

  MovieElement.fromFirestore(DocumentSnapshot ds) {
    voteCount = ds['vote_count'];
    id = ds['id'];
    voteAverage = ds['vote_average'];
    title = ds['title'];
    posterPath = ds['poster_path'];
    genreIds = ds['genre_ids'] != null ? List<int>.from(ds['genre_ids']) : [];
    backdropPath = ds['backdrop_path'];
    overview = ds['overview'];
    releaseDate = ds['release_date'];
  }
}
