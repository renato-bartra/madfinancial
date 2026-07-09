import '../../../../core/services/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository, this._sessionManager);

  final AuthRepository _repository;
  final SessionManager _sessionManager;

  Future<String> call() async {
    final session = await _sessionManager.getCurrentSession();
    if (session == null) {
      throw const _NoSessionException();
    }
    return _repository.refreshToken(
      email: session.email,
      token: session.token,
    );
  }
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}
