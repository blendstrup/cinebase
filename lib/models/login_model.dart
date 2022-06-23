// Packages
import 'package:scoped_model/scoped_model.dart';
// Data
import '../data/repository.dart';

class LoginModel extends Model {
  final repository = Repository();

  void createNewUser({
    required String email,
    required String name,
    required String password,
  }) {
    repository.createNewUser(
      email: email,
      name: name,
      password: password,
      description: 'The user has not set a description yet.',
    );
  }

  Future<bool> validateUserCreation(String email) async {
    var result = await repository.validateUserEmail(email);
    return result;
  }

  Future<List<dynamic>> validateLogin(String email, String password) async {
    var result = await repository.validateLogin(email, password);
    return result;
  }
}
