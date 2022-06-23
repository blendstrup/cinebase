// Packages
import 'package:scoped_model/scoped_model.dart';
// Data
import '../data/repository.dart';
import '../data/firestore_data_parser.dart';

class ReviewModel extends Model {
  final repository = Repository();

  final User user;

  String title;
  String content;

  num rating;
  DateTime date;

  bool edited;

  String authorId;
  String authorName;

  final int movieId;
  final String movieTitle;
  final String movieBackdropPath;

  final String reviewId;

  ReviewModel({
    required this.user,
    required this.title,
    required this.content,
    required this.rating,
    required this.date,
    required this.authorId,
    required this.authorName,
    required this.movieId,
    required this.movieTitle,
    required this.movieBackdropPath,
    required this.reviewId,
    required this.edited,
  });

  void commentOnReview({
    required String authorName,
    required String authorId,
    required String content,
    required String reviewId,
  }) {
    if (content != '')
      repository.commentOnReview(
        authorName: authorName,
        authorId: authorId,
        content: content,
        reviewId: reviewId,
      );
  }

  void replyToComment({
    required String authorName,
    required String authorId,
    required String content,
    required String reviewId,
    required String commentId,
  }) {
    if (content != '')
      repository.replyToComment(
        authorName: authorName,
        authorId: authorId,
        content: content,
        reviewId: reviewId,
        commentId: commentId,
      );
  }

  void updateReview({
    required bool containsSpoilers,
    required String ncontent,
    required num nrating,
    required String ntitle,
    required String reviewId,
  }) {
    repository.updateReview(
      containsSpoilers: containsSpoilers,
      content: ncontent,
      rating: nrating,
      title: ntitle,
      reviewId: reviewId,
    );

    title = ntitle;
    rating = nrating;
    content = ncontent;
    edited = true;
    date = DateTime.now();

    notifyListeners();
  }

  void deleteReview({
    required String reviewId,
    required String authorId,
    required int movieId,
  }) {
    repository.deleteReview(
      reviewId: reviewId,
      authorId: authorId,
      movieId: movieId,
    );
    user.reviewedMovies.remove(movieId);
    notifyListeners();
  }

  Future<User> fetchUserFromId(String userId) async {
    return repository.fetchUserFromId(userId);
  }
}
