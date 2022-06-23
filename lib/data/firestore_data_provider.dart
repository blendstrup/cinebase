// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
// Data
import 'firestore_data_parser.dart';
import 'tmdb_data_parser.dart';

class FirestoreDataProvider {
  final db = FirebaseFirestore.instance;

  Future<List> validateLogin(String email, String password) async {
    final QuerySnapshot result = await db
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    final List<DocumentSnapshot> docs = result.docs;

    if (docs.length == 1)
      return [true, User.fromFirestore(docs[0])];
    else
      return [false, User()];
  }

  Future<bool> validateUserEmail(String email) async {
    final QuerySnapshot result = await db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.length == 1;
  }

  Future<bool> validateListTitle(String title, String userId) async {
    final QuerySnapshot result = await db
        .collection('users/$userId/lists')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    return docs.length == 1;
  }

  Future<DocumentSnapshot> fetchUserFromId(String userId) {
    return db.doc('users/$userId').get();
  }

  void createNewUser({
    required String name,
    required String email,
    required String password,
    required String description,
    required String tmdbGuestId,
  }) {
    db.collection('users').add({
      'name': name,
      'email': email,
      'password': password,
      'description': description,
      'tmdb_guest_session_id': tmdbGuestId,
    }).then((doc) {
      var batch = db.batch();

      batch.set(doc.collection('lists').doc('seen'), {
        'title': 'Movies that I have seen',
        'private': false,
        'three_posters': [],
        'date': DateTime.now(),
      });

      batch.set(doc.collection('lists').doc('tobeseen'), {
        'title': 'Movies that I want to see',
        'private': false,
        'three_posters': [],
        'date': DateTime.now(),
      });

      batch.commit();
    });
  }

  void updateUser({
    required String name,
    required String email,
    required String password,
    required String description,
    required String userId,
  }) {
    db.doc('users/$userId').update({
      'name': name,
      'email': email,
      'password': password,
      'description': description,
    }).then((_) async {
      WriteBatch batch = db.batch();

      await db.collection('reviews').get().then((reviews) async {
        for (var rev in reviews.docs) {
          if (rev['author_id'] == userId) {
            batch.update(rev.reference, {'author_name': name});
          }

          await rev.reference
              .collection('comments')
              .get()
              .then((comments) async {
            for (var com in comments.docs) {
              if (com['author_id'] == userId) {
                batch.update(com.reference, {'author_name': name});
              }

              await com.reference.collection('replies').get().then((replies) {
                for (var rep in replies.docs) {
                  if (rep['author_id'] == userId) {
                    batch.update(rep.reference, {'author_name': name});
                  }
                }
              });
            }
          });
        }
      });

      batch.commit();
    });
  }

  void deleteUser(String userId) {
    db.doc('users/$userId').delete().then((doc) async {
      WriteBatch batch = db.batch();

      await db.collection('users/$userId/lists').get().then((lists) async {
        for (var list in lists.docs) {
          batch.delete(list.reference);

          var subMovies = await list.reference.collection('movies').get();
          for (var movie in subMovies.docs) batch.delete(movie.reference);
        }
      });

      await db.collection('reviews').get().then((reviews) async {
        for (var rev in reviews.docs) {
          if (rev['author_id'] == userId) batch.delete(rev.reference);

          await rev.reference
              .collection('comments')
              .get()
              .then((comments) async {
            for (var com in comments.docs) {
              if (com['author_id'] == userId) batch.delete(com.reference);
              if (rev['author_id'] == userId) batch.delete(com.reference);

              await com.reference.collection('replies').get().then((replies) {
                for (var rep in replies.docs) {
                  if (rep['author_id'] == userId) batch.delete(rep.reference);
                  if (com['author_id'] == userId) batch.delete(rep.reference);
                  if (rev['author_id'] == userId) batch.delete(rep.reference);
                }
              });
            }
          });
        }
      });

      batch.commit();
    });
  }

  void createReview({
    required String authorId,
    required String authorName,
    required bool containsSpoilers,
    required String content,
    required int movieId,
    required String movieTitle,
    required String movieBackdropPath,
    required num rating,
    required String title,
  }) {
    db.collection('reviews').add({
      'author_id': authorId,
      'author_name': authorName,
      'contains_spoilers': containsSpoilers,
      'content': content,
      'date': DateTime.now(),
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_backdrop_path': movieBackdropPath,
      'rating': rating,
      'title': title,
    }).then((doc) => db.doc('users/$authorId').update({
          'reviewed_movies': FieldValue.arrayUnion([movieId]),
        }));
  }

  void updateReview({
    required bool containsSpoilers,
    required String content,
    required num rating,
    required String title,
    required String reviewId,
  }) {
    db.doc('reviews/$reviewId').update({
      'contains_spoilers': containsSpoilers,
      'content': content,
      'rating': rating,
      'title': title,
      'date': DateTime.now(),
      'edited': true,
    });
  }

  void deleteReview({
    required String reviewId,
    required String authorId,
    required int movieId,
  }) {
    db.doc('reviews/$reviewId').delete().then((_) {
      db.doc('users/$authorId').update({
        'reviewed_movies': FieldValue.arrayRemove([movieId])
      });

      WriteBatch batch = db.batch();

      db.collection('reviews/$reviewId/comments').get().then((comments) {
        comments.docs.forEach((com) {
          batch.delete(com.reference);

          com.reference.collection('replies').get().then((replies) {
            replies.docs.forEach((rep) => batch.delete(rep.reference));

            batch.commit();
          });
        });
      });
    });
  }

  void commentOnReview({
    required String authorId,
    required String authorName,
    required String content,
    required String reviewId,
  }) {
    db.collection('reviews/$reviewId/comments').add({
      'author_name': authorName,
      'author_id': authorId,
      'content': content,
      'date': DateTime.now(),
    });
  }

  void replyToComment({
    required String authorId,
    required String authorName,
    required String content,
    required String reviewId,
    required String commentId,
  }) {
    db.collection('reviews/$reviewId/comments/$commentId/replies').add({
      'author_name': authorName,
      'author_id': authorId,
      'content': content,
      'date': DateTime.now(),
    });
  }

  void rateMovie({
    required String userId,
    required num rating,
    required num movieId,
  }) {
    db
        .collection('/users')
        .doc(userId)
        .update({'movie_ratings.$movieId': rating});
  }

  void createList({
    required String userId,
    required String title,
    bool private: false,
  }) {
    db.collection('users/$userId/lists').add({
      'title': title,
      'private': private,
      'three_posters': [],
      'date': DateTime.now(),
    });
  }

  void updateList({
    required String title,
    required bool private,
    required String userId,
    required String listId,
  }) {
    db.doc('users/$userId/lists/$listId').update({
      'title': title,
      'private': private,
    });
  }

  void insertMovieInList({
    required String userId,
    required String listId,
    required MovieElement movie,
  }) async {
    await db.doc('users/$userId/lists/$listId').get().then((doc) => {
          if (doc['three_posters'].length < 3)
            doc.reference.update({
              'three_posters': FieldValue.arrayUnion([movie.posterPath])
            })
        });

    var moviesMatching = await db
        .collection('users/$userId/lists/$listId/movies')
        .where('id', isEqualTo: movie.id)
        .get();

    if (moviesMatching.docs.length < 1)
      db.collection('users/$userId/lists/$listId/movies').add({
        'vote_count': movie.voteCount,
        'id': movie.id,
        'vote_average': movie.voteAverage,
        'title': movie.title,
        'poster_path': movie.posterPath,
        'genre_ids': movie.genreIds,
        'backdrop_path': movie.backdropPath,
        'overview': movie.overview,
        'release_date': movie.releaseDate,
      });
  }

  void deleteMovieFromList({
    required String userId,
    required String listId,
    required MovieElement movie,
  }) async {
    WriteBatch batch = db.batch();

    var doc = await db.doc('users/$userId/lists/$listId').get();
    var count = doc['three_posters'].length;

    if (doc['three_posters'].contains(movie.posterPath)) {
      batch.update(doc.reference, {
        'three_posters': FieldValue.arrayRemove([movie.posterPath])
      });
      count--;
    }

    var movieWithId = await doc.reference
        .collection('movies')
        .where('id', isEqualTo: movie.id)
        .get();

    for (var movie in movieWithId.docs) {
      batch.delete(movie.reference);
    }

    var allMovies = await doc.reference.collection('movies').get();

    for (var mov in allMovies.docs)
      if (mov['id'] == movie.id)
        continue;
      else if (count < 3) {
        batch.update(doc.reference, {
          'three_posters': FieldValue.arrayUnion([mov['poster_path']])
        });
        if (!doc['three_posters'].contains(mov['poster_path'])) count++;
      }

    batch.commit();
  }

  void deleteList({
    required String userId,
    required String listId,
  }) async {
    WriteBatch batch = db.batch();

    batch.delete(db.doc('users/$userId/lists/$listId'));

    await db
        .collection('users/$userId/lists/$listId/movies')
        .get()
        .then((resp) {
      for (var doc in resp.docs) batch.delete(doc.reference);
    });

    batch.commit();
  }
}
