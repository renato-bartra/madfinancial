import '../../../../core/services/auth_session.dart';
import '../../../../core/services/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository, this._sessionManager);

  final AuthRepository _repository;
  final SessionManager _sessionManager;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    final session = await _repository.login(email: email, password: password);
    await _sessionManager.saveSession(session);
    await _sessionManager.markEverRegistered();
    return session;
  }
}
