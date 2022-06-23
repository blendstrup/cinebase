// Packages
import 'package:scoped_model/scoped_model.dart';
// Data
import '../data/firestore_data_parser.dart';
import '../data/tmdb_data_parser.dart';
import '../data/repository.dart';

class UserModel extends Model {
  final repository = Repository();

  User _user;
  User get user => _user;

  String _currentListId = '';
  String _currentListTitle = '';
  bool _currentListPrivate = false;

  String get currentListId => _currentListId;
  String get currentListTitle => _currentListTitle;
  bool get currentListPrivate => _currentListPrivate;

  UserModel(this._user);

  Future<bool> validateUserUpdate(String email) async {
    var result = await repository.validateUserEmail(email);
    return result;
  }

  void updateUser({
    required String name,
    required String password,
    required String email,
    required String description,
    required String userId,
  }) {
    repository.updateUser(
      name: name,
      email: email,
      password: password,
      description: description,
      userId: userId,
    );
    _user.name = name;
    _user.password = password;
    _user.email = email;
    _user.description = description;
    notifyListeners();
  }

  void deleteUser(String userId) => repository.deleteUser(userId);

  Future<bool> validateListTitle(String title) async {
    var result = await repository.validateListTitle(title, _user.docId);
    return result;
  }

  void createList({
    required String title,
    required bool private,
  }) {
    repository.createList(title: title, userId: _user.docId, private: private);
  }

  void updateList({
    required String title,
    required bool private,
    required String userId,
    required String listId,
  }) {
    repository.updateList(
      title: title,
      private: private,
      userId: userId,
      listId: listId,
    );
  }

  void deleteMovieFromList({
    required String userId,
    required String listId,
    required MovieElement movie,
  }) {
    repository.deleteMovieFromList(
      userId: userId,
      listId: listId,
      movie: movie,
    );
  }

  void deleteList({
    required String userId,
    required String listId,
  }) {
    repository.deleteList(userId: userId, listId: listId);
  }

  void updateCurrentList({
    required String currentListId,
    required String currentListTitle,
    required bool currentListPrivate,
  }) {
    _currentListId = currentListId;
    _currentListTitle = currentListTitle;
    _currentListPrivate = currentListPrivate;
    notifyListeners();
  }
}
