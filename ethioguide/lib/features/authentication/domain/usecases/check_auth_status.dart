// This use case now correctly depends on your feature's repository.
import 'package:ethioguide/features/authentication/domain/repositories/auth_repositoryy.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<bool> call() async {
    // It calls the isAuthenticated method that you already implemented
    // in your feature's repository.
    return await repository.isAuthenticated();
  }
}