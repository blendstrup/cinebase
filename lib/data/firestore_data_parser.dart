// Packages
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String docId = '';
  String description = '';
  String email = '';
  Map<String, num> movieRatings = {};
  List<int> reviewedMovies = [];
  String name = '';
  String tmdbGuestId = '';
  String password = '';

  User({
    this.description = '',
    this.email = '',
    this.name = '',
    this.tmdbGuestId = '',
  });

  User.fromFirestore(DocumentSnapshot ds) {
    docId = ds.id.toString();
    tmdbGuestId = ds['tmdb_guest_session_id'];
    description = ds['description'];
    email = ds['email'];
    password = ds['password'];
    movieRatings = ds['movie_ratings'] != null
        ? Map<String, num>.from(ds['movie_ratings'])
        : <String, num>{};
    reviewedMovies = ds['reviewed_movies'] != null
        ? List<int>.from(ds['reviewed_movies'])
        : [];
    name = ds['name'];
  }
}
