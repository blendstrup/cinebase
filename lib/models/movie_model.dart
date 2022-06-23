// Packages
import 'package:scoped_model/scoped_model.dart';
// Data
import '../data/repository.dart';
import '../data/firestore_data_parser.dart';
import '../data/tmdb_data_parser.dart';

const Map<int, String> genres = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

class MovieModel extends Model {
  final repository = Repository();

  //final User _user;
  //User get user => _user;

  final MovieElement _movie;
  MovieElement get movie => _movie;

  //MovieModel(this._user, this._movie);
  MovieModel(this._movie);

  void rateMovie({
    //required String userId,
    //required String guestId,
    required double rating,
    required num movieId,
  }) {
    //user.movieRatings[movie.id.toString()] = rating;
    repository.rateMovie(
      //userId: userId,
      //guestId: guestId,
      rating: rating,
      movieId: movieId,
    );
    notifyListeners();
  }

  void createReview({
    //required String authorId,
    //required String authorName,
    required bool containsSpoilers,
    required String content,
    required int movieId,
    required String movieTitle,
    required String movieBackdropPath,
    //required num rating,
    required String title,
  }) {
    repository.createReview(
      //authorId: authorId,
      //authorName: authorName,
      containsSpoilers: containsSpoilers,
      content: content,
      movieId: movieId,
      movieTitle: movieTitle,
      movieBackdropPath: movieBackdropPath,
      //rating: rating,
      title: title,
    );
    //_user.reviewedMovies.add(movieId);
    notifyListeners();
  }

  void insertMovieInList({
    //required String userId,
    required String listId,
    required MovieElement movie,
  }) {
    repository.insertMovieInList(
      //userId: userId,
      listId: listId,
      movie: movie,
    );
  }
}
