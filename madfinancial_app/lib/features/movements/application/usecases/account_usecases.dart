import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class GetAccountsUseCase {
  const GetAccountsUseCase(this._repository, this._resolveUserId);

  final AccountRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<List<Account>> call() async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.getAll(userId);
  }
}

class CreateAccountUseCase {
  const CreateAccountUseCase(this._repository, this._resolveUserId);

  final AccountRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<Account> call(String description) async {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      throw const _EmptyAccountDescriptionException();
    }
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.create(userId, trimmed);
  }
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}

class _EmptyAccountDescriptionException implements Exception {
  const _EmptyAccountDescriptionException();
  @override
  String toString() => 'El nombre de la cuenta no puede estar vacío.';
}
