import '../../../../core/services/session_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository, this._sessionManager);

  final AuthRepository _repository;
  final SessionManager _sessionManager;

  Future<User> call(RegisterUser user) async {
    final registeredUser = await _repository.register(user);
    await _sessionManager.markEverRegistered();
    return registeredUser;
  }
}
