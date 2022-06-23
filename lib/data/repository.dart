// Data
import 'tmdb_data_parser.dart';
import 'tmdb_data_provider.dart';
import 'firestore_data_parser.dart';
import 'firestore_data_provider.dart';

class Repository {
  final tmdbProvider = TmdbDataProvider();
  final fsProvider = FirestoreDataProvider();

  Future<List<MovieElement>> fetchMovies({
    required int page,
    String query = '',
    String orderBy = '',
    String category = '',
    int voteCountMin = 0,
    String releaseDateMin = '',
    String releaseDateMax = '',
    String genres = '',
  }) async {
    var json = tmdbProvider.fetchMovies(
      page: page,
      query: query,
      orderBy: orderBy,
      category: category,
      voteCountMin: voteCountMin,
      releaseDateMin: releaseDateMin,
      releaseDateMax: releaseDateMax,
      genres: genres,
    );

    MovieResults fetchedMovies = MovieResults.fromJson(await json);
    return fetchedMovies.movies!;
  }

  Future<MovieElement> fetchSingleMovie(num movieId) async {
    Map<String, dynamic> json = await tmdbProvider.fetchSingleMovie(movieId);

    return MovieElement.fromJson(json);
  }

  void rateMovie({
    //required String userId,
    //required String guestId,
    required num rating,
    required num movieId,
  }) {
    /*fsProvider.rateMovie(userId: userId, rating: rating, movieId: movieId);
    tmdbProvider.rateMovie(
      guestId: guestId,
      rating: rating,
      movieId: movieId,
    );*/
  }

  Future<List<dynamic>> validateLogin(String email, String password) async {
    List<dynamic> results = await fsProvider.validateLogin(email, password);
    return results;
  }

  Future<bool> validateUserEmail(String email) async {
    bool boo = await fsProvider.validateUserEmail(email);
    return boo;
  }

  Future<bool> validateListTitle(String title, String userId) async {
    bool boo = await fsProvider.validateListTitle(title, userId);
    return boo;
  }

  Future<User> fetchUserFromId(String userId) async {
    var ds = await fsProvider.fetchUserFromId(userId);
    var user = User.fromFirestore(ds);
    return user;
  }

  void createNewUser({
    required String name,
    required String email,
    required String password,
    required String description,
  }) async {
    String tmdbGuestId = await tmdbProvider.getGuestSessionId();

    fsProvider.createNewUser(
        name: name,
        email: email,
        password: password,
        description: description,
        tmdbGuestId: tmdbGuestId);
  }

  void updateUser({
    required String name,
    required String email,
    required String password,
    required String description,
    required String userId,
  }) {
    fsProvider.updateUser(
      name: name,
      email: email,
      password: password,
      description: description,
      userId: userId,
    );
  }

  void deleteUser(String userId) => fsProvider.deleteUser(userId);

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
    /*fsProvider.createReview(
      authorId: authorId,
      authorName: authorName,
      containsSpoilers: containsSpoilers,
      content: content,
      movieId: movieId,
      movieTitle: movieTitle,
      movieBackdropPath: movieBackdropPath,
      rating: rating,
      title: title,
    );*/
  }

  void updateReview({
    required bool containsSpoilers,
    required String content,
    required num rating,
    required String title,
    required String reviewId,
  }) {
    fsProvider.updateReview(
      containsSpoilers: containsSpoilers,
      content: content,
      rating: rating,
      title: title,
      reviewId: reviewId,
    );
  }

  void deleteReview({
    required String reviewId,
    required String authorId,
    required int movieId,
  }) {
    fsProvider.deleteReview(
      reviewId: reviewId,
      authorId: authorId,
      movieId: movieId,
    );
  }

  void commentOnReview({
    required String authorId,
    required String authorName,
    required String content,
    required String reviewId,
  }) {
    fsProvider.commentOnReview(
      authorId: authorId,
      authorName: authorName,
      content: content,
      reviewId: reviewId,
    );
  }

  void replyToComment({
    required String authorId,
    required String authorName,
    required String content,
    required String reviewId,
    required String commentId,
  }) {
    fsProvider.replyToComment(
      authorId: authorId,
      authorName: authorName,
      content: content,
      reviewId: reviewId,
      commentId: commentId,
    );
  }

  void createList({
    required String userId,
    required String title,
    bool private: false,
  }) {
    fsProvider.createList(
      userId: userId,
      title: title,
      private: private,
    );
  }

  void updateList({
    required String title,
    required bool private,
    required String userId,
    required String listId,
  }) {
    fsProvider.updateList(
      title: title,
      private: private,
      userId: userId,
      listId: listId,
    );
  }

  void insertMovieInList({
    //required String userId,
    required String listId,
    required MovieElement movie,
  }) {
    /*sProvider.insertMovieInList(
      userId: userId,
      listId: listId,
      movie: movie,
    );*/
  }

  void deleteMovieFromList({
    required String userId,
    required String listId,
    required MovieElement movie,
  }) {
    fsProvider.deleteMovieFromList(
      userId: userId,
      listId: listId,
      movie: movie,
    );
  }

  void deleteList({
    required String userId,
    required String listId,
  }) {
    fsProvider.deleteList(userId: userId, listId: listId);
  }
}
