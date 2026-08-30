import '../../domain/entities/transfer.dart';
import '../../domain/repositories/movement_repository.dart';

class CreateTransferUseCase {
  const CreateTransferUseCase(this._repository, this._resolveUserId);

  final MovementRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<TransferPair> call(TransferDraft draft) async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.createTransfer(userId, draft);
  }
}

class UpdateTransferUseCase {
  const UpdateTransferUseCase(this._repository, this._resolveUserId);

  final MovementRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<TransferPair> call(
    String transferUuid,
    TransferDraft draft,
  ) async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.updateTransfer(transferUuid, userId, draft);
  }
}

class DeleteTransferUseCase {
  const DeleteTransferUseCase(this._repository);

  final MovementRepository _repository;

  Future<void> call(String transferUuid) =>
      _repository.deleteTransfer(transferUuid);
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}
